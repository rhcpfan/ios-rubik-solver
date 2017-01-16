//
//  EdgeBasedCubeDetector.hpp
//  RubikSolver
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#ifndef EdgeBasedCubeDetector_hpp
#define EdgeBasedCubeDetector_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>

#endif /* EdgeBasedCubeDetector_hpp */


class EdgeBasedCubeDetector
{
private:
    
    // Helper functions
    cv::Point ComputeWeightCenterHu(const std::vector<cv::Point> &c);
    bool PointsIntersect(cv::Point2f A1, cv::Point2f B1, cv::Point2f A2, cv::Point2f B2, cv::Point &intersectionPoint);
    bool ParallelogramTest(std::vector<cv::Point> rectangleContour, int distanceThreshold);
    double ComputeSquareSidesScore(std::vector<cv::Point> rectangleContour);
    
    // Filters
    void ApplyFilter(EdgeBasedCubeDetector *obj, void(EdgeBasedCubeDetector::*function)(), std::string filterDescription = "");
    
    void FilterByDistanceToImageEdges();
    void FilterByShape();
    void FilterByArea();
    void FilterBySimmilarityBetweenSides();
    void FilterByParallelismBetweenSides();
    
    void SeparatePatchesIntoSides(std::vector<std::vector<cv::Point>> &topFaceRegions, std::vector<std::vector<cv::Point>> &leftFaceRegions, std::vector<std::vector<cv::Point>> &rightFaceRegions);
    void ExtractFaceCorners(std::vector<std::vector<cv::Point>> topFaceRegions, std::vector<cv::Point2f>& topFaceCorners, std::vector<std::vector<cv::Point>> leftFaceRegions, std::vector<cv::Point2f>& leftFaceCorners, std::vector<std::vector<cv::Point>> rightFaceRegions, std::vector<cv::Point2f>& rightFaceCorners, bool isFirstThreeFacesImage);
    
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
    
public:
    EdgeBasedCubeDetector();
    ~EdgeBasedCubeDetector();
    
    cv::Mat inputImage;
    std::vector<std::vector<cv::Point>> patchContours;
    
    void BinarizeImage(const cv::Mat &inputImage, cv::Mat &binaryImage);
    void SegmentFaces(const cv::Mat &inputImage,
                      cv::Mat &outputImage,
                      cv::Mat& topFaceImage,
                      cv::Mat& leftFaceImage,
                      cv::Mat & rightFaceImage,
                      bool isFirstThreeFacesImage);
};
