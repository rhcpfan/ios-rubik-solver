#ifndef SVMTrainer_hpp
#define SVMTrainer_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

#endif /* ColorDetector_hpp */

enum CubeColors
{
	YELLOW,
	RED,
	BLUE,
	GREEN,
	WHITE,
	ORANGE,
	UNKNOWN
};

class SVMTrainer
{
private:
	std::vector<std::pair<std::vector<cv::Mat>, std::vector<int>>> patchTrainingSamples;

    static std::vector<cv::Mat> GetColorPatchesFromCubeFaceImage(const cv::Mat & inputImage);
    static std::vector<std::vector<float>> ExtractFeaturesForPatch(const cv::Mat & colorPatchImage);

    void AssignColorsForTrainingPatchesAtIndex(int faceImageIndex, std::string faceColors);

public:
    SVMTrainer();
    ~SVMTrainer();

    void LoadTrainingData(std::vector<cv::Mat> faceImages, std::vector<std::string> cubeColors);
    void TrainSVM(std::string outputFolderPath, std::string outputFilePath);
};

