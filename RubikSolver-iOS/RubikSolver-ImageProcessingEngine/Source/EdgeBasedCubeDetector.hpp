//
//  EdgeBasedCubeDetector.hpp
//  RubikSolver
//
//  Created by Andrei Ciobanu on 11/07/16.
//  Copyright © 2016 GTeam. All rights reserved.
//

#ifndef EdgeBasedCubeDetector_hpp
#define EdgeBasedCubeDetector_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

#endif /* EdgeBasedCubeDetector_hpp */


class EdgeBasedCubeDetector
{
private:
    
    bool PointsIntersect(cv::Point2f A1, cv::Point2f B1, cv::Point2f A2, cv::Point2f B2, cv::Point &intersectionPoint);
    cv::Point ComputeWeightCenter(const std::vector<cv::Point> &c);
    double ComputeSquareSidesScore(std::vector<cv::Point> rectangleContour);
    bool ParallelogramTest(std::vector<cv::Point> rectangleContour, int distanceThreshold);
    
    
    
    void ExtractTopFaceCorners(const std::vector<std::vector<cv::Point>> &faceRegions,
                               const cv::Size &imageSize,
                               std::vector<cv::Point2f> &cornerPoints);
    
    void ExtractLeftFaceCorners(const std::vector<std::vector<cv::Point>> &faceRegions,
                                const cv::Size &imageSize,
                                std::vector<cv::Point2f> &cornerPoints);
    
    
    void ExtractRightFaceCorners(const std::vector<std::vector<cv::Point>> &faceRegions,
                                 const cv::Size &imageSize,
                                 std::vector<cv::Point2f> &cornerPoints);
    
    void ApplyPerspectiveTransform(const cv::Mat& inputImage,
                                   cv::Mat& outputImage,
                                   const std::vector<cv::Point2f>& inputPoints,
                                   const cv::Size& outputSize);
    
    
    // Pre-defined mask containing all regions (top, left and right)
    cv::Mat regionsMaskImage;
    
    
    
public:
    EdgeBasedCubeDetector();
    ~EdgeBasedCubeDetector();
    
    void SetRegionsMask(const cv::Mat &regionsMask);
    
    void BinarizeImage(const cv::Mat &inputImage, cv::Mat &binaryImage);
    void SegmentFaces(const cv::Mat &inputImage,
                      cv::Mat &outputImage,
                      cv::Mat& topFaceImage, 
                      cv::Mat& leftFaceImage, 
                      cv::Mat & rightFaceImage,
                      bool isFirstThreeFacesImage);
};