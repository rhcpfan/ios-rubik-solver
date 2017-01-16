//
//  EdgeBasedCubeDetector.cpp
//  RubikSolver
//
//  Created by rhcpfan on 15/01/17.
//  Copyright © 2017 HomeApps. All rights reserved.
//

#ifdef _WIN32
#include "stdafx.h"
#endif

#include "EdgeBasedCubeDetector.hpp"

EdgeBasedCubeDetector::EdgeBasedCubeDetector()
{
    
}

EdgeBasedCubeDetector::~EdgeBasedCubeDetector()
{
}

// Computes the intersection location between the segments of line
// formed by points A1-A2 and B1-B2
bool EdgeBasedCubeDetector::PointsIntersect(cv::Point2f A1, cv::Point2f B1, cv::Point2f A2, cv::Point2f B2,
                                            cv::Point &intersectionPoint)
{
    cv::Point2f x = A2 - A1;
    cv::Point2f d1 = B1 - A1;
    cv::Point2f d2 = B2 - A2;
    
    float cross = d1.x * d2.y - d1.y * d2.x;
    if (std::abs(cross) < 1e-8)
        return false;
    
    double t1 = (x.x * d2.y - x.y * d2.x) / cross;
    intersectionPoint = A1 + d1 * t1;
    return true;
}

cv::Point EdgeBasedCubeDetector::ComputeWeightCenterHu(const std::vector<cv::Point>& c)
{
    auto moments = cv::moments(c, false);
    return cv::Point(moments.m10 / moments.m00, moments.m01 / moments.m00);
}

double EdgeBasedCubeDetector::ComputeSquareSidesScore(std::vector<cv::Point> rectangleContour)
{
    auto perimeter = cv::arcLength(rectangleContour, true);
    auto meanSideLength = perimeter / 4.0;
    
    auto score = 0.0;
    
    for (auto j = 0; j < 4; j++)
    {
        auto sideLength = cv::norm(rectangleContour[j] - rectangleContour[(j + 1) % 4]);
        score += MIN(sideLength, meanSideLength) / static_cast<double>(MAX(sideLength, meanSideLength));
    }
    
    return 4 - score;
}

bool EdgeBasedCubeDetector::ParallelogramTest(std::vector<cv::Point> rectangleContour, int distanceThreshold)
{
    auto pointOrder = std::vector<int>{ 0, 1, 2, 3, 0, 2, 1, 3, 0, 3, 1, 2 };
    int parallelFound = 0;
    
    auto wCenter = ComputeWeightCenterHu(rectangleContour);
    
    for (size_t i = 0; i < pointOrder.size(); i += 4)
    {
        auto p1 = rectangleContour[pointOrder[i]];
        auto p2 = rectangleContour[pointOrder[i + 1]];
        auto p3 = rectangleContour[pointOrder[i + 2]];
        auto p4 = rectangleContour[pointOrder[i + 3]];
        
        auto intersectionPoint = cv::Point(-1, -1);
        auto intersects = PointsIntersect(p1, p2, p3, p4, intersectionPoint);
        
        if (intersects)
        {
            auto distanceToIntersection = cv::norm(intersectionPoint - wCenter);
            if (distanceToIntersection > 100)
            {
                parallelFound += 1;
            }
        }
        else
        {
            parallelFound += 1;
        }
    }
    
    if (parallelFound > 1)
    {
        return true;
    }
    return false;
}

void EdgeBasedCubeDetector::ExtractTopFaceCorners(const std::vector<std::vector<cv::Point>>& faceRegions,
                                                  const cv::Size& imageSize,
                                                  std::vector<cv::Point2f> &cornerPoints)
{
    auto topPoint = cv::Point(imageSize.width / 2, 0);
    auto bottomPoint = cv::Point(imageSize.width / 2, imageSize.height);
    auto rightSidePoint = cv::Point(imageSize.width, 200);
    auto leftSidePoint = cv::Point(0, 255);
    
    auto leftFace = *std::min_element(faceRegions.begin(), faceRegions.end(), [&](std::vector<cv::Point> a, std::vector<cv::Point> b)
                                      {
                                          return (cv::norm(ComputeWeightCenterHu(a) - leftSidePoint) < cv::norm(ComputeWeightCenterHu(b) - leftSidePoint));
                                      });
    auto rightFace = *std::min_element(faceRegions.begin(), faceRegions.end(), [&](std::vector<cv::Point> a, std::vector<cv::Point> b)
                                       {
                                           return (cv::norm(ComputeWeightCenterHu(a) - rightSidePoint) < cv::norm(ComputeWeightCenterHu(b) - rightSidePoint));
                                       });
    auto topFace = *std::min_element(faceRegions.begin(), faceRegions.end(), [&](std::vector<cv::Point> a, std::vector<cv::Point> b)
                                     {
                                         return (cv::norm(ComputeWeightCenterHu(a) - bottomPoint) > cv::norm(ComputeWeightCenterHu(b) - bottomPoint));
                                     });
    auto bottomFace = *std::min_element(faceRegions.begin(), faceRegions.end(), [&](std::vector<cv::Point> a, std::vector<cv::Point> b)
                                        {
                                            return (cv::norm(ComputeWeightCenterHu(a) - topPoint) > cv::norm(ComputeWeightCenterHu(b) - topPoint));
                                        });
    
    auto topLeftCorner = *std::min_element(leftFace.begin(), leftFace.end(), [&](cv::Point a, cv::Point b) { return a.x < b.x; });
    auto topRightCorner = *std::min_element(topFace.begin(), topFace.end(), [&](cv::Point a, cv::Point b) { return a.y < b.y; });
    auto bottomLeftCorner = *std::min_element(bottomFace.begin(), bottomFace.end(), [&](cv::Point a, cv::Point b) { return a.y > b.y; });
    auto bottomRightCorner = *std::min_element(rightFace.begin(), rightFace.end(), [&](cv::Point a, cv::Point b) { return a.x > b.x; });
    
    cornerPoints = std::vector<cv::Point2f>(4);
    cornerPoints[0] = topLeftCorner;
    cornerPoints[1] = topRightCorner;
    cornerPoints[2] = bottomRightCorner;
    cornerPoints[3] = bottomLeftCorner;
}

void EdgeBasedCubeDetector::ExtractLeftFaceCorners(const std::vector<std::vector<cv::Point>>& faceRegions, const cv::Size& imageSize, std::vector<cv::Point2f>& cornerPoints)
{
    auto centerPoint = cv::Point(imageSize.width / 2, imageSize.height / 2);
    auto bottomRightPoint = cv::Point(imageSize.width / 2, imageSize.height);
    auto bottomLeftPoint = cv::Point(0, (imageSize.height / 4) * 3);
    auto leftSidePoint = cv::Point(0, 255);
    
    auto leftMinDistance = INT_MAX;
    auto rightMinDistance = INT_MAX;
    auto topMinDistance = INT_MAX;
    auto bottomMinDistance = INT_MAX;
    auto leftMinDistancePoint = cv::Point(-1, -1);
    auto rightMinDistancePoint = cv::Point(-1, -1);
    auto topMinDistancePoint = cv::Point(-1, -1);
    auto bottomMinDistancePoint = cv::Point(-1, -1);
    
    for (size_t i = 0; i < faceRegions.size(); i++)
    {
        for (size_t j = 0; j < faceRegions[i].size(); j++)
        {
            cv::Point currentPoint = faceRegions[i][j];
            auto leftDistance = cv::norm(currentPoint - leftSidePoint);
            auto rightDistance = cv::norm(currentPoint - bottomRightPoint);
            auto topDistance = cv::norm(currentPoint - centerPoint);
            auto bottomDistance = cv::norm(currentPoint - bottomLeftPoint);
            
            if (leftDistance < leftMinDistance)
            {
                leftMinDistance = leftDistance;
                leftMinDistancePoint = currentPoint;
            }
            if (rightDistance < rightMinDistance)
            {
                rightMinDistance = rightDistance;
                rightMinDistancePoint = currentPoint;
            }
            if (topDistance < topMinDistance)
            {
                topMinDistance = topDistance;
                topMinDistancePoint = currentPoint;
            }
            if (bottomDistance < bottomMinDistance)
            {
                bottomMinDistance = bottomDistance;
                bottomMinDistancePoint = currentPoint;
            }
        }
    }
    
    cornerPoints = std::vector<cv::Point2f>(4);
    cornerPoints[0] = leftMinDistancePoint;
    cornerPoints[1] = topMinDistancePoint;
    cornerPoints[2] = rightMinDistancePoint;
    cornerPoints[3] = bottomMinDistancePoint;
}

void EdgeBasedCubeDetector::ExtractRightFaceCorners(const std::vector<std::vector<cv::Point>>& faceRegions, const cv::Size& imageSize, std::vector<cv::Point2f>& cornerPoints)
{
    auto centerPoint = cv::Point(imageSize.width / 2, imageSize.height / 2);
    auto topRightSidePoint = cv::Point(imageSize.width, (imageSize.height / 4));
    auto bottomRightPoint = cv::Point(imageSize.width, (imageSize.height / 4) * 3);
    auto bottomLeftPoint = cv::Point(imageSize.width / 2, imageSize.height);
    
    auto leftMinDistance = INT_MAX;
    auto rightMinDistance = INT_MAX;
    auto topMinDistance = INT_MAX;
    auto bottomMinDistance = INT_MAX;
    auto leftMinDistancePoint = cv::Point(-1, -1);
    auto rightMinDistancePoint = cv::Point(-1, -1);
    auto topMinDistancePoint = cv::Point(-1, -1);
    auto bottomMinDistancePoint = cv::Point(-1, -1);
    
    for (size_t i = 0; i < faceRegions.size(); i++)
    {
        for (size_t j = 0; j < faceRegions[i].size(); j++)
        {
            cv::Point currentPoint = faceRegions[i][j];
            auto topRightDistance = cv::norm(currentPoint - topRightSidePoint);
            auto bottomRightDistance = cv::norm(currentPoint - bottomRightPoint);
            auto topDistance = cv::norm(currentPoint - centerPoint);
            auto bottomDistance = cv::norm(currentPoint - bottomLeftPoint);
            
            if (topDistance < leftMinDistance)
            {
                leftMinDistance = topDistance;
                leftMinDistancePoint = currentPoint;
            }
            if (bottomRightDistance < rightMinDistance)
            {
                rightMinDistance = bottomRightDistance;
                rightMinDistancePoint = currentPoint;
            }
            if (topRightDistance < topMinDistance)
            {
                topMinDistance = topRightDistance;
                topMinDistancePoint = currentPoint;
            }
            if (bottomDistance < bottomMinDistance)
            {
                bottomMinDistance = bottomDistance;
                bottomMinDistancePoint = currentPoint;
            }
        }
    }
    
    cornerPoints = std::vector<cv::Point2f>(4);
    cornerPoints[0] = leftMinDistancePoint;
    cornerPoints[1] = topMinDistancePoint;
    cornerPoints[2] = rightMinDistancePoint;
    cornerPoints[3] = bottomMinDistancePoint;
}

void EdgeBasedCubeDetector::ApplyPerspectiveTransform(const cv::Mat& inputImage, cv::Mat& outputImage, const std::vector<cv::Point2f>& inputPoints, const cv::Size &outputSize)
{
    std::vector<cv::Point2f> outputPoints;
    outputPoints.push_back(cv::Point2f(0, 0));
    outputPoints.push_back(cv::Point2f(outputSize.width - 1, 0));
    outputPoints.push_back(cv::Point2f(outputSize.width - 1, outputSize.height - 1));
    outputPoints.push_back(cv::Point2f(0, outputSize.height - 1));
    
    //Apply the perspective transformation
    auto perspectiveMatrix = cv::getPerspectiveTransform(inputPoints, outputPoints);
    cv::warpPerspective(inputImage, outputImage, perspectiveMatrix, outputSize);
}

void EdgeBasedCubeDetector::BinarizeImage(const cv::Mat &inputImage, cv::Mat &binaryImage)
{
    // Apply dilation (morphological edge detection)
    cv::Mat dilatedImage;
    cv::dilate(inputImage, dilatedImage, cv::Mat(), cv::Point(-1, -1), 3);
    
    // The edges are represented by the differences between the original image
    // and the dilated one
    cv::Mat edges_mat;
    cv::absdiff(inputImage, dilatedImage, edges_mat);
    
    // Transform to grayscale by summing up all 3 channels
    std::vector<cv::Mat> edges_channels;
    cv::split(edges_mat, edges_channels);
    cv::Mat binaryEdges = edges_channels[0] + edges_channels[1] + edges_channels[2];
    
    // Binarize the image by using a small threshold
    cv::threshold(binaryEdges, binaryEdges, 25, 255, CV_THRESH_BINARY);
    cv::erode(binaryEdges, binaryEdges, cv::Mat());
    cv::dilate(binaryEdges, binaryEdges, cv::Mat());
    
    // Invert the edge map (for square detection)
    binaryImage = ~binaryEdges;
}

void EdgeBasedCubeDetector::SegmentFaces(const cv::Mat& inImage, cv::Mat &outputImage, cv::Mat& topFaceImage, cv::Mat& leftFaceImage, cv::Mat & rightFaceImage, bool isFirstThreeFacesImage)
{
    // Downscale the image
    cv::resize(inImage, this->inputImage, cv::Size(720, 1280));
    
    cv::Mat binary_input;
    this->BinarizeImage(inputImage, binary_input);
    
    // Find all the contours
    cv::findContours(binary_input.clone(), patchContours, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE);
    
    // ***************************************************************
    // 1. Filter the contours by the distance to the edge of the image
    // ***************************************************************
    this->ApplyFilter(this, &EdgeBasedCubeDetector::FilterByDistanceToImageEdges, "Distance to image edges");
    
    
    // *********************************************************************
    // 2. Filter by the shape of the contour (approxPolyDP and area ratio)
    // *********************************************************************
    this->ApplyFilter(this, &EdgeBasedCubeDetector::FilterByShape, "Shape");
    
    
    // *********************************************************************
    // 4. Filter further more by area of the detected squares
    // *********************************************************************
    this->ApplyFilter(this, &EdgeBasedCubeDetector::FilterByArea, "Area (upper and lower bounds)");
    
    
    // *********************************************************************
    // 5. Filter further more by simmilarity between sides
    // *********************************************************************
    this->ApplyFilter(this, &EdgeBasedCubeDetector::FilterBySimmilarityBetweenSides, "Simmilarity between sides");
    
    
    // *********************************************************************
    // 6. Filter further more by parallelism between sides
    // *********************************************************************
    this->ApplyFilter(this, &EdgeBasedCubeDetector::FilterByParallelismBetweenSides, "Parallelism between sides");
    
    
    // Declare a binary mask that is supposed to contain only cube patches
    auto cubeMaskDisplay = cv::Mat(inputImage.rows, inputImage.cols, CV_8UC3, cv::Scalar::all(0));
    
    // Draw the cube patches on the mask
    cv::drawContours(cubeMaskDisplay, patchContours, -1, cv::Scalar(255, 255, 0), CV_FILLED);
    
    std::vector<std::vector<cv::Point>> topFaceRegions;
    std::vector<std::vector<cv::Point>> leftFaceRegions;
    std::vector<std::vector<cv::Point>> rightFaceRegions;
    
    this->SeparatePatchesIntoSides(topFaceRegions, leftFaceRegions, rightFaceRegions);
    
    if (topFaceRegions.size() == 0 || leftFaceRegions.size() == 0 || rightFaceRegions.size() == 0)
    {
        throw std::out_of_range("Not all sides have been detected. Please retake the picture.");
    }
    
    std::vector<cv::Point2f> topFaceCorners, leftFaceCorners, rightFaceCorners;
    this->ExtractFaceCorners(topFaceRegions, topFaceCorners, leftFaceRegions, leftFaceCorners, rightFaceRegions, rightFaceCorners, isFirstThreeFacesImage);
    
    
    cv::Size outputFaceImageSize(300, 300);
    
    this->ApplyPerspectiveTransform(inputImage, topFaceImage, topFaceCorners, outputFaceImageSize);
    this->ApplyPerspectiveTransform(inputImage, leftFaceImage, leftFaceCorners, outputFaceImageSize);
    this->ApplyPerspectiveTransform(inputImage, rightFaceImage, rightFaceCorners, outputFaceImageSize);
    
    cv::circle(cubeMaskDisplay, topFaceCorners[0], 15, cv::Scalar(0, 0, 255), -1);
    cv::circle(cubeMaskDisplay, topFaceCorners[1], 15, cv::Scalar(0, 0, 255), -1);
    cv::circle(cubeMaskDisplay, topFaceCorners[2], 15, cv::Scalar(0, 0, 255), -1);
    cv::circle(cubeMaskDisplay, topFaceCorners[3], 15, cv::Scalar(0, 0, 255), -1);
    
    cv::circle(cubeMaskDisplay, leftFaceCorners[0], 15, cv::Scalar(0, 255, 0), -1);
    cv::circle(cubeMaskDisplay, leftFaceCorners[1], 15, cv::Scalar(0, 255, 0), -1);
    cv::circle(cubeMaskDisplay, leftFaceCorners[2], 15, cv::Scalar(0, 255, 0), -1);
    cv::circle(cubeMaskDisplay, leftFaceCorners[3], 15, cv::Scalar(0, 255, 0), -1);
    
    cv::circle(cubeMaskDisplay, rightFaceCorners[0], 15, cv::Scalar(255, 0, 0), -1);
    cv::circle(cubeMaskDisplay, rightFaceCorners[1], 15, cv::Scalar(255, 0, 0), -1);
    cv::circle(cubeMaskDisplay, rightFaceCorners[2], 15, cv::Scalar(255, 0, 0), -1);
    cv::circle(cubeMaskDisplay, rightFaceCorners[3], 15, cv::Scalar(255, 0, 0), -1);
    
    outputImage = cubeMaskDisplay.clone();
}

void EdgeBasedCubeDetector::ApplyFilter(EdgeBasedCubeDetector *obj, void(EdgeBasedCubeDetector::*function)(), std::string filterDescription)
{
#ifdef DRAW_FILTER_RESULTS
    std::vector<std::vector<cv::Point>> oldContours = obj->patchContours;
#endif
    
    (obj->*function)();
    
#ifdef DRAW_FILTER_RESULTS
    cv::Mat filterResults = cv::Mat(obj->inputImage.rows, obj->inputImage.cols, CV_8UC3, cv::Scalar::all(0));
    cv::drawContours(filterResults, oldContours, -1, cv::Scalar(0, 0, 255), CV_FILLED);
    cv::drawContours(filterResults, patchContours, -1, cv::Scalar(0, 255, 0), CV_FILLED);
    
    std::string text = filterDescription;
    cv::Size textSize = cv::getTextSize(text, CV_FONT_NORMAL, 1, 1, 0);
    cv::rectangle(filterResults, cv::Rect(cv::Point(20, 20), textSize), cv::Scalar::all(0), -1);
    cv::putText(filterResults, text, cv::Point(20, 40), CV_FONT_NORMAL, 1, cv::Scalar(0, 255, 255));
    
    cv::namedWindow("Filtered", 0);
    cv::imshow("Filtered", filterResults);
    cv::waitKey(0);
#endif
}

void EdgeBasedCubeDetector::FilterByDistanceToImageEdges()
{
    int leftThreshold = 30;
    int rightThreshold = 30;
    int topThreshold = 200;
    int bottomThreshold = 200;
    
    patchContours.erase(std::remove_if(std::begin(patchContours), std::end(patchContours), [&](std::vector<cv::Point> contour)
                                       {
                                           auto wCenter = this->ComputeWeightCenterHu(contour);
                                           auto d1 = wCenter.x < leftThreshold;
                                           auto d2 = wCenter.y < topThreshold;
                                           auto d3 = wCenter.x > inputImage.cols - rightThreshold;
                                           auto d4 = wCenter.y > inputImage.rows - bottomThreshold;
                                           
                                           return d1 || d2 || d3 || d4;
                                       }), std::end(patchContours));
}

void EdgeBasedCubeDetector::FilterByShape()
{
    std::vector<std::vector<cv::Point>> squareContours;
    
    // Approximate the contours through a polygon (DP algorithm)
    for (size_t i = 0; i < patchContours.size(); i++)
    {
        auto epsilonParameter = (5.0 / 100.0) * cv::arcLength(patchContours[i], true);
        cv::approxPolyDP(patchContours[i], patchContours[i], epsilonParameter, true);
    }
    
    // See what contours are simmilar to a rectangle
    for (size_t i = 0; i < patchContours.size(); i++)
    {
        // Ignore small areas
        auto contourArea = cv::contourArea(patchContours[i]);
        if (contourArea < 200) continue;
        
        // ************************************************************
        // 2. Filter the contours by the number of edges (square -> 4)
        // ************************************************************
        if (patchContours[i].size() == 4)
        {
            // *********************************************************************
            // 3. Filter further more based on shape
            // Take the area of the minimum area rectangle of the contour
            // and compare it to the contour area. Squares should have a high ratio.
            // *********************************************************************
            auto minAreaRect = cv::minAreaRect(patchContours[i]);
            auto minAreaRectArea = minAreaRect.size.area();
            auto sizeRatio = MIN(contourArea, minAreaRectArea) / MAX(contourArea, minAreaRectArea);
            
            if (sizeRatio > 0.5)
            {
                // Draw the contours
                //cv::circle(outputImage, wCenter, 2, color, -1);
                squareContours.push_back(patchContours[i]);
            }
        }
    }
    
    patchContours = squareContours;
}

void EdgeBasedCubeDetector::FilterByArea()
{
    auto upperBound = (2 / 100.0) * inputImage.size().area();
    auto lowerBound = (0.1 / 100.0) * inputImage.size().area();
    
    //Remove large square contours
    patchContours.erase(std::remove_if(std::begin(patchContours), std::end(patchContours), [&](std::vector<cv::Point> contour)
                                       {
                                           auto cArea = cv::contourArea(contour);
                                           bool tooBig = cArea > upperBound;
                                           bool tooSmall = cArea < lowerBound;
                                           
                                           return (tooBig || tooSmall);
                                       }), std::end(patchContours));
}

void EdgeBasedCubeDetector::FilterBySimmilarityBetweenSides()
{
    patchContours.erase(std::remove_if(std::begin(patchContours), std::end(patchContours), [&](std::vector<cv::Point> contour)
                                       {
                                           auto score = this->ComputeSquareSidesScore(contour);
                                           return score > 1;
                                       }), std::end(patchContours));
}

void EdgeBasedCubeDetector::FilterByParallelismBetweenSides()
{
    patchContours.erase(std::remove_if(std::begin(patchContours), std::end(patchContours), [&](std::vector<cv::Point> contour)
                                       {
                                           auto isParallelogram = this->ParallelogramTest(contour, 100);
                                           return isParallelogram == false;
                                       }), std::end(patchContours));
}

void EdgeBasedCubeDetector::SeparatePatchesIntoSides(std::vector<std::vector<cv::Point>> &topFaceRegions, std::vector<std::vector<cv::Point>> &leftFaceRegions, std::vector<std::vector<cv::Point>> &rightFaceRegions)
{
    auto leftSideTwoThirds = cv::Point(0, (int)(inputImage.rows / 2.65));
    auto rightSideTwoThirds = cv::Point(inputImage.cols, (int)(inputImage.rows / 2.65));
    auto centerPoint = cv::Point(inputImage.cols / 2, inputImage.rows / 2);
    
    auto topRegion = std::vector<cv::Point>{
        cv::Point(0, 0), cv::Point(inputImage.cols, 0),
        rightSideTwoThirds, centerPoint, leftSideTwoThirds
    };
    
    auto leftRegion = std::vector<cv::Point>{
        leftSideTwoThirds, centerPoint, cv::Point(inputImage.cols / 2, inputImage.rows), cv::Point(0, inputImage.rows)
    };
    
    auto rightRegion = std::vector<cv::Point>{
        rightSideTwoThirds, centerPoint, cv::Point(inputImage.cols / 2, inputImage.rows), cv::Point(inputImage.cols, inputImage.rows)
    };
    
    for (auto patch : patchContours)
    {
        // Compute the weight center
        cv::Point wCenter = this->ComputeWeightCenterHu(patch);
        
        if (cv::pointPolygonTest(topRegion, wCenter, false) >= 0)
        {
            topFaceRegions.push_back(patch);
        }
        else if (cv::pointPolygonTest(leftRegion, wCenter, false) >= 0)
        {
            leftFaceRegions.push_back(patch);
        }
        else if (cv::pointPolygonTest(rightRegion, wCenter, false) >= 0)
        {
            rightFaceRegions.push_back(patch);
        }
    }
}

void EdgeBasedCubeDetector::ExtractFaceCorners(std::vector<std::vector<cv::Point>> topFaceRegions, std::vector<cv::Point2f>& topFaceCorners, std::vector<std::vector<cv::Point>> leftFaceRegions, std::vector<cv::Point2f>& leftFaceCorners, std::vector<std::vector<cv::Point>> rightFaceRegions, std::vector<cv::Point2f>& rightFaceCorners, bool isFirstThreeFacesImage)
{
    this->ExtractTopFaceCorners(topFaceRegions, inputImage.size(), topFaceCorners);
    this->ExtractLeftFaceCorners(leftFaceRegions, inputImage.size(), leftFaceCorners);
    this->ExtractRightFaceCorners(rightFaceRegions, inputImage.size(), rightFaceCorners);
    
    if (!isFirstThreeFacesImage)
    {
        std::vector<cv::Point2f> rearangedTopFace, rearangedLeftFace, rearangedRightFace;
        rearangedTopFace.push_back(topFaceCorners[1]);
        rearangedTopFace.push_back(topFaceCorners[2]);
        rearangedTopFace.push_back(topFaceCorners[3]);
        rearangedTopFace.push_back(topFaceCorners[0]);
        topFaceCorners = rearangedTopFace;
        
        rearangedLeftFace.push_back(leftFaceCorners[2]);
        rearangedLeftFace.push_back(leftFaceCorners[3]);
        rearangedLeftFace.push_back(leftFaceCorners[0]);
        rearangedLeftFace.push_back(leftFaceCorners[1]);
        leftFaceCorners = rearangedLeftFace;
        
        rearangedRightFace.push_back(rightFaceCorners[2]);
        rearangedRightFace.push_back(rightFaceCorners[3]);
        rearangedRightFace.push_back(rightFaceCorners[0]);
        rearangedRightFace.push_back(rightFaceCorners[1]);
        rightFaceCorners = rearangedRightFace;
    }
}
