//
//  EdgeBasedCubeDetector.hpp
//  RubikSolver
//
//  Created by Andrei Ciobanu on 11/07/16.
//  Copyright © 2016 GTeam. All rights reserved.
//

#ifndef ColorDetector_hpp
#define ColorDetector_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

#endif /* ColorDetector_hpp */

class ColorDetector
{
private:
	std::vector<float> GetPixelFeatures(const cv::Mat &bgrImage, const cv::Mat &hsvImage, const cv::Point &location);
	std::vector<std::vector<float>> GetFaceFeatures(const cv::Mat& bgrImage, const cv::Mat& hsvImage);
	cv::Ptr<cv::ml::SVM> _svmClassifier;
public:
	ColorDetector();
	~ColorDetector();

	void LoadSVMFromFile(const std::string &filePath);
	std::vector<std::string> RecognizeColors(const cv::Mat &cubeFaceImage);
};

