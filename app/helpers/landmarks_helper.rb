module LandmarksHelper
  def landmarks_for_json
    @landmarks.to_json
  end
end
