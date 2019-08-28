#ifndef _5X5_BOARD_API_H
#define _5X5_BOARD_API_H


#include <stdint.h>

#include <iostream>
#include <vector>

using std::vector;

#ifdef _WIN32
#include <opencv/cv.h>
#else 
#include <opencv2/opencv.hpp>
#endif
using namespace cv;




typedef struct
{
    CvPoint2D32f tl;

    CvPoint2D32f tr;

    CvPoint2D32f bl;

    CvPoint2D32f br;



}VecRect;

typedef struct
{
    CvSeq*  _contour_p;
    VecRect _vecrect_p;
    CvSeq*  _contour_dp;
    CvBox2D _box_p;
}BoxedContour;

typedef struct
{
	BoxedContour _centerContour;
	uint32_t            _value;
}Board_5X5;
typedef struct {
    int x;
    int y;
    int w;
    int h;
    uint32_t value;
}Board_5x5_Other_BRIDGE;


double vec_cross(CvPoint2D32f vec1,CvPoint2D32f vec2);
double vec_dot(CvPoint2D32f vec1,CvPoint2D32f vec2);
CvPoint2D32f vec_add(CvPoint2D32f vec1,CvPoint2D32f vec2);
CvPoint2D32f vec_dim(CvPoint2D32f vec1,CvPoint2D32f vec2);
CvPoint2D32f vec_mul(CvPoint2D32f vec1,float d);
CvPoint2D32f vec_normalize(CvPoint2D32f vec);
//void sauvola(unsigned char * grayImage, unsigned char * biImage, int w, int h, double k, int windowSize);
float point_distance(CvPoint2D32f p1,CvPoint2D32f p2);
VecRect contour42vecRect(const CvSeq* contour);
VecRect box2d2vecRect(const CvBox2D& box);
void cp_point(CvPoint & dst,const CvPoint2D32f & src);
typedef vector<BoxedContour> ContourVec;
typedef vector<Board_5X5>       Board_5X5Vec;
typedef vector<Board_5x5_Other_BRIDGE>   Board_Bridge_Vec;

void getBoard_5x5_Vec_VALUE_CHECK(const ContourVec& out_pass_vec, Board_5X5Vec& board_5x5_vec, IplImage* prcessGrayImg,IplImage* processImg);
#ifdef _WIN32
void find_board_5x5_bgra_file(const char* file_name, int width, int height, Board_5X5Vec& out_contour_vec, float angle_precision);
#endif


void find_board_bridge_bgra_data(void* data, int width, int height,int bytePerRow, Board_Bridge_Vec& out_bridge_vec, float angle_precision);
#endif
