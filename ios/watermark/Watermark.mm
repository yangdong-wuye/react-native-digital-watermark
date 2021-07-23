//
//  Watermark.cpp
//  DigitalWatermark
//
//  Created by wuye on 2020/7/31.
//  Copyright © 2020 dabank. All rights reserved.
//
#ifdef __cplusplus
#undef NO
#undef YES
#include <bitset>
#include <sstream>
#include <opencv2/opencv.hpp>
#include <string>
#include <opencv2/core/core_c.h>
#include <set>
#include <opencv2/imgproc/types_c.h>
using namespace std;
using namespace cv;

static char base32[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z'};

#define N (57 * 5)

static const int L = 20;
//
std::string GetBin(int n)
{
    std::string res;
    if (n % 2 == 1)
    {
        res = "1";
    }
    else
    {
        res = "0";
    }
    for (int i = 0; i < 4; i++)
    {
        n /= 2;
        if (n % 2 == 1)
        {
            res = "1" + res;
        }
        else
        {
            res = "0" + res;
        }
    }
    return res;
}

std::string Addr2Bin(std::string addr)
{
    std::string res = "";
    for (int i = 0; i < addr.size(); i++)
    {
        for (int j = 0; j < sizeof(base32); j++)
        {
            if (addr[i] == base32[j])
            {
                res += GetBin(j);
            }
        }
    }
    return res;
}

int AddWatermark(const std::string &addr, const char *src, const char *dst)
{
    bitset<N> bs(addr);
    cv::Mat img_src = imread(src, cv::IMREAD_COLOR);
    if (img_src.empty())
    {
        return 1;
    }
    srand(img_src.cols + img_src.rows);
    std::set<uint32_t> si;
    for (int i = 0; i < bs.size(); i++)
    {
        int X = rand() % (img_src.rows - 2);
        int Y = rand() % (img_src.cols - 2);
        uint32_t index = X * 10000 + Y;
        if (si.find(index) == si.end())
        {
            if (bs.test(i))
            {
                if (img_src.at<Vec3b>(X, Y)[0] > (255 - L))
                {
                    img_src.at<Vec3b>(X, Y)[0] = 255 - L;
                }
                img_src.at<Vec3b>(X + 1, Y)[0] = img_src.at<Vec3b>(X, Y)[0] + L;
                if (img_src.at<Vec3b>(X, Y)[1] > (255 - L))
                {
                    img_src.at<Vec3b>(X, Y)[1] = 255 - L;
                }

                img_src.at<Vec3b>(X + 1, Y)[1] = img_src.at<Vec3b>(X, Y)[1] + L;
                if (img_src.at<Vec3b>(X, Y)[2] > (255 - L))
                {
                    img_src.at<Vec3b>(X, Y)[2] = (255 - L);
                }
                img_src.at<Vec3b>(X + 1, Y)[2] = img_src.at<Vec3b>(X, Y)[2] + L;
            }
            else
            {
                if (img_src.at<Vec3b>(X, Y)[0] < L)
                {
                    img_src.at<Vec3b>(X, Y)[0] = L;
                }
                img_src.at<Vec3b>(X + 1, Y)[0] = img_src.at<Vec3b>(X, Y)[0] - L;
                if (img_src.at<Vec3b>(X, Y)[1] < L)
                {
                    img_src.at<Vec3b>(X, Y)[1] = L;
                }
                img_src.at<Vec3b>(X + 1, Y)[1] = img_src.at<Vec3b>(X, Y)[1] - L;
                if (img_src.at<Vec3b>(X, Y)[2] < L)
                {
                    img_src.at<Vec3b>(X, Y)[2] = L;
                }
                img_src.at<Vec3b>(X + 1, Y)[2] = img_src.at<Vec3b>(X, Y)[2] - L;
            }
            si.insert(index);
        }
        else
        {
            i--;
        }
    }
    cv::imwrite(dst, img_src);
    return 0;
}

std::string DecWatermark(const char *src, const char *dst)
{
    cv::Mat img = imread(src, cv::IMREAD_COLOR);
    if (img.empty())
    {
        return "";
    }
    srand(img.cols + img.rows);
    std::string res = "";
    std::set<uint32_t> si;
    for (int i = 0; i < N; i++)
    {
        int X = rand() % (img.rows - 2);
        int Y = rand() % (img.cols - 2);
        uint32_t index = X * 10000 + Y;
        if (si.find(index) == si.end())
        {
            if ((img.at<Vec3b>(X + 1, Y)[0] + img.at<Vec3b>(X + 1, Y)[1] + img.at<Vec3b>(X + 1, Y)[2]) >
                (img.at<Vec3b>(X, Y)[0] + img.at<Vec3b>(X, Y)[1] + img.at<Vec3b>(X, Y)[2]))
            {
                res = "1" + res;
            }
            else
            {
                res = "0" + res;
            }
            si.insert(index);
        }
        else
        {
            i--;
        }
    }
    std::stringstream ss;
    bitset<N> bs(res);
    for (int i = N - 1; i < bs.size(); i = i - 5)
    {
        int index = bs.test(i) * 16 + bs.test(i - 1) * 8 + bs.test(i - 2) * 4 + bs.test(i - 3) * 2 + bs.test(i - 4);
        ss << base32[index];
    }
    std::string addr = ss.str();

    Mat gray_image;
    cvtColor(img, gray_image, CV_BGR2GRAY);
    Mat img_addr;
    cv::Size s;
    s.width = 600;
    s.height = gray_image.rows * 600 / gray_image.cols;
    cv::resize(gray_image, img_addr, s);
    threshold(img_addr, img_addr, 0, 128, CV_THRESH_OTSU);
    cv::putText(img_addr, addr.substr(0, 30), cv::Point(10, (s.height / 2) - 20), cv::FONT_HERSHEY_PLAIN, 2, cv::Scalar(255, 255, 255), 2);
    cv::putText(img_addr, addr.substr(30), cv::Point(10, (s.height / 2) + 20), cv::FONT_HERSHEY_PLAIN, 2, cv::Scalar(255, 255, 255), 2);
    cv::imwrite(dst, img_addr);
    return addr;
}

long nativeCode(string jSrcFileName, string jDstFileName, string jAddr)
{
    const char *scr_file = jSrcFileName.c_str();
    const char *dst_file = jDstFileName.c_str();
    const char *addr_ = jAddr.c_str();
    std::string addr = Addr2Bin(addr_);
    return AddWatermark(addr, scr_file, dst_file);
}

long nativeDecode(string jSrcFileName, string jDstFileName)
{
    const char *scr_file = jSrcFileName.c_str();
    const char *dst_file = jDstFileName.c_str();
    std::string str = DecWatermark(scr_file, dst_file);
    if (str == "")
    {
        return 1;
    }
    return 0;
}
#endif
