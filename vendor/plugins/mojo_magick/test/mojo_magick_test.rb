require 'test/unit'
require File::expand_path(File::join(File::dirname(__FILE__), '..', 'init'))
require 'fileutils'
require 'tempfile'

class MojoMagickTest < Test::Unit::TestCase

  # we keep a fixtures path and a working path so that we can easily test image
  # manipulation routines without tainting the original images
  def setup
    @fixtures_path = File.expand_path(File::join(File.dirname(__FILE__), 'fixtures'))
    @working_path = File::join(@fixtures_path, 'tmp')
  end

  def reset_images
    FileUtils::rm_r(@working_path) if File::exists?(@working_path)
    FileUtils::mkdir(@working_path)
    Dir::glob(File::join(@fixtures_path, '*')).each do |file|
      FileUtils::cp(file, @working_path) if File::file?(file)
    end
  end

  def test_image_management
    reset_images
    test_image = File::join(@working_path, '5742.jpg')
    orig_image_size = File::size(test_image)
    retval = MojoMagick::get_image_size(test_image)
    assert_equal orig_image_size, File::size(test_image)
    assert_equal 500, retval[:height]
    assert_equal 333, retval[:width]

    # test basic resizing
    size_test_temp = Tempfile::new('mojo_test')
    size_test = size_test_temp.path
    retval = MojoMagick::resize(test_image, size_test, {:width=>100, :height=>100})
    assert_equal size_test, retval
    assert_equal orig_image_size, File::size(test_image)
    assert_equal retval, size_test
    new_dimensions = MojoMagick::get_image_size(size_test)
    assert_equal 100, new_dimensions[:height]
    assert_equal 67, new_dimensions[:width]

    # we should be able to resize image right over itself
    retval = MojoMagick::resize(test_image, test_image, {:width=>100, :height=>100})
    assert_equal test_image, retval
    assert_not_equal orig_image_size, File::size(test_image)
    new_dimensions = MojoMagick::get_image_size(test_image)
    assert_equal 100, new_dimensions[:height]
    assert_equal 67, new_dimensions[:width]

    # image shouldn't resize if we specify very large dimensions and specify "shrink_only"
    reset_images
    orig_image_size = File::size(test_image)
    retval = MojoMagick::shrink(test_image, test_image, {:width=>1000, :height=>1000})
    assert_equal test_image, retval
    new_dimensions = MojoMagick::get_image_size(test_image)
    assert_equal 500, new_dimensions[:height]
    assert_equal 333, new_dimensions[:width]
    # image should resize if we specify small dimensions and shrink_only
    retval = MojoMagick::shrink(test_image, test_image, {:width=>1000, :height=>100})
    assert_equal test_image, retval
    new_dimensions = MojoMagick::get_image_size(test_image)
    assert_equal 100, new_dimensions[:height]
    assert_equal 67, new_dimensions[:width]

    # image shouldn't resize if we specify small dimensions and expand_only
    reset_images
    orig_image_size = File::size(test_image)
    retval = MojoMagick::expand(test_image, test_image, {:width=>10, :height=>10})
    assert_equal test_image, retval
    new_dimensions = MojoMagick::get_image_size(test_image)
    assert_equal 500, new_dimensions[:height]
    assert_equal 333, new_dimensions[:width]
    # image should resize if we specify large dimensions and expand_only
    retval = MojoMagick::expand(test_image, test_image, {:width=>1000, :height=>1000})
    assert_equal test_image, retval
    new_dimensions = MojoMagick::get_image_size(test_image)
    assert_equal 1000, new_dimensions[:height]
    assert_equal 666, new_dimensions[:width]


    # test bad images
    bad_image = File::join(@working_path, 'not_an_image.jpg')
    zero_image = File::join(@working_path, 'zero_byte_image.jpg')
    assert_raise(MojoMagick::MojoFailed) {MojoMagick::get_image_size(bad_image)}
    assert_raise(MojoMagick::MojoFailed) {MojoMagick::get_image_size(zero_image)}
    assert_raise(MojoMagick::MojoFailed) {MojoMagick::get_image_size('/file_does_not_exist_here_ok.jpg')}
  end

  def test_resource_limits
    orig_limits = MojoMagick::get_default_limits
    assert_equal 5, orig_limits.size
    orig_limits_test = orig_limits.dup
    orig_limits_test.delete_if do |resource, value|
      assert [:area, :map, :disk, :memory, :file].include?(resource), "Found unexpected resource #{resource}"
      true
    end
    assert_equal 0, orig_limits_test.size

    # set area to 32mb limit
    MojoMagick::set_limits(:area => '32mb')
    new_limits = MojoMagick::get_current_limits
    assert_equal '32mb', new_limits[:area]

    # remove limits on area
    MojoMagick::remove_limits(:area)
    new_limits = MojoMagick::get_current_limits
    assert_equal orig_limits[:area], new_limits[:area]

    # set memory to 64 mb, disk to 0 and
    MojoMagick::set_limits(:memory => '64mb', :disk => '0b')
    new_limits = MojoMagick::get_current_limits(:show_actual_values => true)
    assert_equal 64 * (2 ** 20), new_limits[:memory]
    assert_equal 0, new_limits[:disk]

    # return to original/default limit values
    MojoMagick::unset_limits
    new_limits = MojoMagick::get_current_limits
    assert_equal orig_limits, new_limits
  end
end
