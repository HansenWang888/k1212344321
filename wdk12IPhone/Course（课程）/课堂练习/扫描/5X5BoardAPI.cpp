#include "5X5BoardAPI.h"
#include <vector>
#include <iostream>
#include <time.h>
#include <algorithm>
#include <stdint.h>
#ifdef _WIN32
#include <io.h>
#endif
#define printf
int g_frame_width;
int g_frame_height;
int g_min_area;
using std::max;
using std::min;
using namespace cv;



bool closely(float v1, float v2, float errorV){
    bool ret = fabs(v1 - v2) < errorV;
    return ret;
}


bool closely_point(CvPoint2D32f p1, CvPoint2D32f p2, float distance){
    return sqrt(pow((p1.x - p2.x), 2.0) + pow((p2.y - p1.y), 2.0)) < distance;
}

bool closely_axis(float angle, float angle_precision){
    while (angle >= 0.f){
        angle -= 90.f;
    }
    while (angle <= 0.f){
        angle += 90.f;
    }
    
    return (angle < angle_precision) || ((90.f - angle) < angle_precision);
}

float box_area(CvBox2D box){
    return box.size.width * box.size.height;
}
float rect_area(CvRect rect){
    return (float)rect.width*rect.height;
}

double vec_dot(CvPoint2D32f vec1,CvPoint2D32f vec2){
    float m1 = point_distance(vec1, cvPoint2D32f(0, 0));
    CvPoint2D32f n1 = cvPoint2D32f(vec1.x/m1, vec1.y/m1);
    float m2 = point_distance(vec2, cvPoint2D32f(0, 0));
    CvPoint2D32f n2 = cvPoint2D32f(vec2.x/m2, vec2.y/m2);
    
    return n1.x*n2.x+n1.y*n2.y;
}
double vec_cross(CvPoint2D32f vec1,CvPoint2D32f vec2){
    return vec1.x*vec2.y-vec1.y*vec2.x;
}
CvPoint2D32f vec_add(CvPoint2D32f vec1,CvPoint2D32f vec2){
    return cvPoint2D32f(vec1.x+vec2.x, vec1.y+vec2.y);
}
CvPoint2D32f vec_dim(CvPoint2D32f vec1,CvPoint2D32f vec2){
    return cvPoint2D32f(vec1.x-vec2.x, vec1.y-vec2.y);
}
CvPoint2D32f vec_mul(CvPoint2D32f vec1,float d){
    return cvPoint2D32f(vec1.x*d, vec1.y*d);
}
CvPoint2D32f vec_normalize(CvPoint2D32f vec){
    float dis = point_distance(vec, cvPoint2D32f(0, 0));
    return cvPoint2D32f(vec.x/dis, vec.y/dis);
}

void fillBoxedContour(BoxedContour*  contour, CvSeq* pContour_p, CvSeq* pContour_dp, CvBox2D box_p)		{
    if (!contour) return;
    contour->_contour_p = pContour_p;
    contour->_box_p = box_p;
    //  contour->_vecrect_p = box2d2vecRect(box_p);
  
    contour->_contour_dp = pContour_dp;
    contour->_vecrect_p  = contour42vecRect(pContour_dp);
}
float point_distance(CvPoint2D32f p1,CvPoint2D32f p2){
    return sqrt(pow((p2.x-p1.x),2.0)+pow((p2.y-p1.y),2.0));
}

void cp_point(CvPoint & dst,const CvPoint2D32f & src){
    dst.x = src.x;
    dst.y = src.y;
}
VecRect contour42vecRect(const CvSeq* contour){
    CvBox2D box2d = cvMinAreaRect2(contour);
    VecRect vRect;
    if(contour->total != 4) return vRect;
    CvPoint2D32f point[4];
    for(int i = 0 ; i < 4 ; ++i){
        CvPoint* pnt =(CvPoint*)cvGetSeqElem(contour, i);
        point[i].x = pnt->x;
        point[i].y = pnt->y;
    }
    int idx = 0;
    float minx = 0.f;
    for(int i = 0 ; i < 4 ; ++i){
        float vx = point[i].x - box2d.center.x;
        float vy = point[i].y - box2d.center.y;
        if(vx<=0.f && vy<=0.f && vx<minx){
            idx = i;
            minx = vx;
        }
    }
    int bridx = (idx+2)%4;
    vRect.tl = point[idx];
    vRect.br = point[bridx];
    
    if(vec_cross(vec_dim(vRect.tl, vRect.br),vec_dim(point[(bridx+1)%4], vRect.br)    )<0){
        vRect.tr = point[(idx+1)%4];
        vRect.bl = point[(bridx+1)%4];
    }
    else{
        vRect.bl = point[(idx+1)%4];
        vRect.tr = point[(bridx+1)%4];
    }
    
    return vRect;    
}

int lll = 0;
void filter_boxedContour_angle_arearatio1(CvSeq* contour, ContourVec& out_contour_vec, float angle_precision,CvMemStorage* storage){
    
    for (; contour != NULL; contour = contour->h_next){
        
        //printf("%d\n",lll);
        ++lll;
        do{
            //if (contour->v_next == NULL) break;
            if(contour->total<4) break;
           // printf("total:%d",contour->total);
            if(cvContourArea(contour)<g_min_area) break;
           // printf("area:%f",cvContourArea(contour));
            CvBox2D box_p = cvMinAreaRect2(contour);
            CvSeq* pContour_dp = NULL;
            //  pContour_dp = cvApproxPoly(p_contour_p, sizeof(CvContour), NULL, CV_POLY_APPROX_DP, 0.02*cvContourPerimeter(p_contour_p));
            
            CvSeq* xxx =  cvConvexHull2(contour,storage,CV_CLOCKWISE,1);
            
            //pContour_dp = cvApproxPoly(contour, sizeof(CvContour), NULL, CV_POLY_APPROX_DP, 0.05*cvArcLength(contour,CV_WHOLE_SEQ,0),1);
           // pContour_dp = cvApproxPoly(xxx, xxx->header_size, NULL, CV_POLY_APPROX_DP, 0.1*cvArcLength(xxx,CV_WHOLE_SEQ,0));
            
            pContour_dp = cvApproxPoly(contour, sizeof(CvContour), NULL, CV_POLY_APPROX_DP, 0.1*cvArcLength(contour,CV_WHOLE_SEQ,0));
            //printf("total:%d,%d\n",pContour_dp->total,contour->total);
            if(pContour_dp->total < 4) break;
            
            
            BoxedContour boxed_contour_c;
            fillBoxedContour(&boxed_contour_c, contour,pContour_dp,box_p);
            
            //            if(closely(boxed_contour_c._vecrect_p.w/boxed_contour_c._vecrect_p.h
            //                       ,1.f,0.3f)){
            out_contour_vec.push_back(boxed_contour_c);
            //            }
            
        } while (0);
        //”–◊”Ω⁄µ„µ›πÈ
        if (contour->v_next){
            filter_boxedContour_angle_arearatio1(contour->v_next, out_contour_vec, angle_precision,storage);
        }
    }
    
}
void getBoard_5x5_Vec_VALUE_CHECK(const ContourVec& out_pass_vec, Board_5X5Vec& out_board_vec, IplImage* prcessGrayImg,IplImage* processImg){
    
    for(int i = 0 ; i < out_pass_vec.size() ; ++i){
        
        
        Point2f origin[4];
        origin[0] =out_pass_vec[i]._vecrect_p.tl;
        origin[1] =out_pass_vec[i]._vecrect_p.tr;
        origin[2] =out_pass_vec[i]._vecrect_p.br;
        origin[3] =out_pass_vec[i]._vecrect_p.bl;
        Point2f dst[4];
        dst[0] = cvPoint2D32f(0, 0);
        dst[1] = cvPoint2D32f(50, 0);
        dst[2] = cvPoint2D32f(50, 50);
        dst[3] = cvPoint2D32f(0, 50);
        
        Mat affmat =  getPerspectiveTransform(origin , dst);
        warpPerspective(cvarrToMat(prcessGrayImg), cvarrToMat(processImg), affmat,Size(50,50));
        

        cvSetImageROI(processImg, cvRect(20, 20, 10,10 ));
        

        int xxxx = cvAvg(processImg).val[0];
        cvResetImageROI(processImg);
        cvThreshold(processImg, processImg, xxxx, 255, CV_THRESH_BINARY);
 
        bool isColorSample = true;
        uint32_t value = 0;
        for(int y = 0 ; y < 5 ; ++y){
            for(int x = 0 ; x < 5 ; ++x ){
                CvRect area = cvRect(x*10+2, y*10+2, 6, 6);
                cvSetImageROI(processImg, area);
                float lightf = cvAvg(processImg).val[0];
                //int  lightn = lightf>125 ? 1 : 0;
                int  lightn = 0 ;
                if(lightf>170){
                    lightn = 1;
                }else if(lightf < 85){
                    lightn = 0;
                }else{
                    isColorSample = false;
                }
                value = (value) | lightn << (x + 5 * y);
                cvResetImageROI(processImg);
                if(isColorSample == false) break;
            }
            if(isColorSample == false) break;
        }
        if(isColorSample == true){
            Board_5X5    board_5x5;
            board_5x5._centerContour = out_pass_vec[i];
        
            board_5x5._value = value;
            out_board_vec.push_back(board_5x5);
        }
    }
    
}
IplImage* loadImgFromBGRAData(void* data, int width, int height,int bytepPerRow){
    CvSize img_size;
    img_size.width = width;
    img_size.height = height;
    IplImage* ret = cvCreateImageHeader(img_size, IPL_DEPTH_8U, 4);
    cvSetData(ret, data, bytepPerRow);
    return ret;
}


void find_board_bridge_bgra_data(void* data, int width, int height,int bytePerRow, Board_Bridge_Vec& out_bridge_vec, float angle_precision){
    Board_5X5Vec out_board_vec;
    g_frame_width = width;
    g_frame_height = height;
    g_min_area = g_frame_width*g_frame_height/10000;
    IplImage* src = NULL;
    IplImage* img = NULL;
    
    IplImage* processImg = NULL;
    IplImage* prcessGrayImg = NULL;
    CvMemStorage* storage = cvCreateMemStorage(0);;
    CvSeq* contour = 0;
    int contours = 0;
    
    src = loadImgFromBGRAData(data,width,height,bytePerRow);
    
    img = cvCreateImage(cvGetSize(src), IPL_DEPTH_8U, 1);
    processImg = cvCreateImage(cvSize(50, 50), IPL_DEPTH_8U, 1);
    cvCvtColor(src, img, CV_BGR2GRAY);

    prcessGrayImg = cvCloneImage(img);

    
    //Mat element = getStructuringElement(MORPH_RECT, Size(5, 5));
    //进行形态学操作
    
    //morphologyEx(cvarrToMat(img),cvarrToMat(img), MORPH_OPEN, element);
    cvCanny(img, img, 80, 250);
    //cvCanny(img, img, 20, 120);

   // element = getStructuringElement(MORPH_RECT, Size(5, 5));
    //进行形态学操作
    
   // morphologyEx(cvarrToMat(img),cvarrToMat(img), MORPH_GRADIENT, element);
    

    contours = cvFindContours(img, storage, &contour, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    ContourVec out_pass_vec;
    printf("---------4---------\n");
    lll = 0;
    filter_boxedContour_angle_arearatio1(contour, out_pass_vec, 10,storage);
    printf("---------5----%d---%d--\n",lll,out_pass_vec.size());
    getBoard_5x5_Vec_VALUE_CHECK(out_pass_vec, out_board_vec, prcessGrayImg,processImg);
    printf("---------6---------\n");
  
    
    //cvReleaseImage(&src);
    
    
    for(int i = 0 ; i < out_board_vec.size() ; ++i){
        CvContour* pContour = (CvContour*)out_board_vec[i]._centerContour._contour_p;
        Board_5x5_Other_BRIDGE bridge;
        bridge.x = pContour->rect.x;
        bridge.y = pContour->rect.y;
        bridge.w = pContour->rect.width;
        bridge.h = pContour->rect.height;
        bridge.value = out_board_vec[i]._value;
        out_bridge_vec.push_back(bridge);
    }
      cvReleaseMemStorage(&storage);
    cvReleaseImageHeader(&src);
    cvReleaseImage(&img);
    cvReleaseImage(&prcessGrayImg);
    cvReleaseImage(&processImg);
}
#ifdef _WIN32
void find_board_5x5_bgra_file(const char* file_name, int width, int height, Board_5X5Vec& out_contour_vec, float angle_precision){
    FILE* fd = fopen(file_name, "rb");
    if (fd == NULL) {
        printf("open file faild:%s\n", file_name);
        return;
    }
    int file_length = _filelength(_fileno(fd));
    char* data = (char*)malloc(file_length);
    fread(data, 1, file_length, fd);
    fclose(fd);
    find_board_5x5_bgra_data(data, width, height,out_contour_vec,angle_precision);
}
#endif
