#include "stdafx.h"
#include "SVMTrainer.hpp"

SVMTrainer::SVMTrainer() {}
SVMTrainer::~SVMTrainer() {}

std::vector<cv::Mat> SVMTrainer::GetColorPatchesFromCubeFaceImage(const cv::Mat& inputImage)
{

    cv::Mat bgrImage;
    cv::cvtColor(inputImage, bgrImage, CV_RGBA2BGR);

	// Select the sample size as 5% of the image width
	auto sampleSize = bgrImage.cols * 0.05;
	auto sampleDistance = (bgrImage.cols / 3.0) / 2 - (sampleSize / 2);

	// Take samples from the image (small squares from the center of the cubie)
	cv::Rect sampleRectangle = cv::Rect(sampleDistance, sampleDistance, sampleSize, sampleSize);
	std::vector<cv::Mat> faceSamples;

	for (auto j = 0; j < 3; j++)
	{
		for (auto i = 0; i < 3; i++)
		{
			sampleRectangle.x = sampleDistance + (i * bgrImage.cols / 3);
			sampleRectangle.y = sampleDistance + (j * bgrImage.rows / 3);
			auto patchImage = bgrImage(sampleRectangle);

			faceSamples.push_back(patchImage);
		}
	}

	return faceSamples;
}

std::vector<std::vector<float>> SVMTrainer::ExtractFeaturesForPatch(const cv::Mat& colorPatchImage)
{
	if (!colorPatchImage.data) return std::vector<std::vector<float>>();

	cv::Mat hsvPatchImage;
	cv::cvtColor(colorPatchImage, hsvPatchImage, CV_BGR2HSV);

	std::vector<std::vector<float>> featureArray;

	for (auto i = 0; i < colorPatchImage.rows; i++)
	{
		for (auto j = 0; j < colorPatchImage.cols; j++)
		{
			auto pixelBGR = colorPatchImage.at<cv::Vec3b>(i, j);
			auto pixelHSV = hsvPatchImage.at<cv::Vec3b>(i, j);

			std::vector<float> patchFeatures;
			patchFeatures.push_back(pixelBGR.val[0]);
			patchFeatures.push_back(pixelBGR.val[1]);
			patchFeatures.push_back(pixelBGR.val[2]);
			patchFeatures.push_back(pixelHSV.val[0]);
			patchFeatures.push_back(pixelHSV.val[1]);
			patchFeatures.push_back(pixelHSV.val[2]);

			featureArray.push_back(patchFeatures);
		}
	}

	return featureArray;
}

void SVMTrainer::AssignColorsForTrainingPatchesAtIndex(int faceImageIndex, std::string faceColors)
{
    for (auto colorChar : faceColors) {
        switch (colorChar)
        {
            case 'W':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::WHITE);
                break;
            case 'R':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::RED);
                break;
            case 'G':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::GREEN);
                break;
            case 'O':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::ORANGE);
                break;
            case 'B':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::BLUE);
                break;
            case 'Y':
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::YELLOW);
                break;
            default:
                patchTrainingSamples[faceImageIndex].second.push_back(CubeColors::UNKNOWN);
        }
    }
}

void SVMTrainer::LoadTrainingData(std::vector<cv::Mat> faceImages, std::vector<std::string> cubeColors)
{
    for (size_t index = 0; index < faceImages.size(); index++) {
        patchTrainingSamples.push_back(std::pair<std::vector<cv::Mat>, std::vector<int>>(GetColorPatchesFromCubeFaceImage(faceImages[index]), {}));
        AssignColorsForTrainingPatchesAtIndex((int)index, cubeColors[index]);
    }
}

void SVMTrainer::TrainSVM(std::string outputFolderPath, std::string outputFilePath)
{
	//matrix to hold the training samples
	cv::Mat data = cv::Mat(0, 6, CV_32F, cv::Scalar::all(0.0));

	//matrix to hold the labels of each taining sample
	cv::Mat classes = cv::Mat(0, 1, CV_32S, cv::Scalar::all(0.0));
	
	// Prepare data for training
	for (auto trainingSample : patchTrainingSamples) 
	{
		if (trainingSample.second.size() == 0) continue;

		for (size_t i = 0; i < trainingSample.first.size(); i++)
		{
			auto patchFeatures = ExtractFeaturesForPatch(trainingSample.first[i]);
			auto classRow = cv::Mat(1, 1, CV_32SC1, cv::Scalar::all(trainingSample.second[i]));
			
			for (auto featureVector : patchFeatures)
			{
				cv::Mat1f dataRow = (cv::Mat1f(1, 6) << featureVector[0], featureVector[1], featureVector[2], featureVector[3], featureVector[4], featureVector[5]);
				data.push_back(dataRow);
				classes.push_back(classRow);
			}
		}		
	}

	// Train the SVM
	auto svmClassifier = cv::ml::SVM::create();
	svmClassifier->setType(cv::ml::SVM::C_SVC);
	svmClassifier->setKernel(cv::ml::SVM::LINEAR);
	svmClassifier->setC(1);

	svmClassifier->train(data, cv::ml::ROW_SAMPLE, classes);

	// Save it to a YML file
	svmClassifier->save(outputFilePath);
}
