require 'test/spec'

context "Empty context" do
  # should.not.raise
end

context "Outer context" do
  context "Inner context" do
    specify "is nested" do
    end
    specify "has multiple empty specifications" do
    end
  end
  context "Second Inner context" do
    context "Inmost context" do
      specify "works too!" do
      end
      specify "whoo!" do
      end
    end
    specify "is indented properly" do
    end
    specify "still runs in order of definition" do
    end
  end
end

class SpecializedTestCase < ::Test::Unit::TestCase
  def test_truth
    assert true
  end
end

context "Outer context with class", SpecializedTestCase do
  context "Inner context" do
    specify "is outer context class" do
      self.should.be.a.kind_of SpecializedTestCase
    end
  end
  context "Inner context with class", Test::Unit::TestCase do
    specify "is specified context class" do
      self.should.be.a.kind_of Test::Unit::TestCase
    end
  end
end
