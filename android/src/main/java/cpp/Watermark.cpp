#include <jni.h>
#include <string>
#include <bitset>
#include <sstream>
#include <android/log.h>
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
            res += "1";
        }
        else
        {
            res += "0";
        }
    }
    return res;
}

std::string str2Bin(const std::string& str)
{
    std::string res;
    for (char i : str)
    {
        for (int j = 0; j < sizeof(base32); j++)
        {
            if (i == base32[j])
            {
                res += GetBin(j);
            }
        }
    }
    return res;
}

int addWatermark(const std::string &text, const char *src, const char *dst)
{
    bitset<N> bs(text);
    cv::Mat img_src = imread(src, cv::IMREAD_COLOR);
    if (img_src.empty())
    {
        return 1;
    }
    srand(img_src.cols + img_src.rows);
    std::set<uint32_t> si;
    for (int i = 0; i < bs.size(); i++)
    {
        int X = random() % (img_src.rows - 2);
        int Y = random() % (img_src.cols - 2);
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

std::string extractingWatermark(const char *src, const char *dst)
{
    cv::Mat img = imread(src, cv::IMREAD_COLOR);
    if (img.empty())
    {
        return "";
    }
    srand(img.cols + img.rows);
    std::string res;
    std::set<uint32_t> si;
    for (int i = 0; i < N; i++)
    {
        int X = random() % (img.rows - 2);
        int Y = random() % (img.cols - 2);
        uint32_t index = X * 10000 + Y;
        if (si.find(index) == si.end())
        {
            if ((img.at<Vec3b>(X + 1, Y)[0] + img.at<Vec3b>(X + 1, Y)[1] + img.at<Vec3b>(X + 1, Y)[2]) >
                (img.at<Vec3b>(X, Y)[0] + img.at<Vec3b>(X, Y)[1] + img.at<Vec3b>(X, Y)[2]))
            {
                res += "1";
            }
            else
            {
                res += "0";
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

/**
 * 添加水印
 */
extern "C" JNIEXPORT
    jlong JNICALL
    Java_com_wuye_watermark_Watermark_buildWatermark(JNIEnv *env, jclass instance, jstring _src, jstring _dst,
                                            jstring _text)
{
    const char *src = env->GetStringUTFChars(_src, nullptr);
    const char *dst = env->GetStringUTFChars(_dst, nullptr);
    const char *text = env->GetStringUTFChars(_text, nullptr);

    std::string add_text = str2Bin(text);
    return addWatermark(add_text, src, dst);
}

/**
 * 提取水印
 */
extern "C" JNIEXPORT
    jlong JNICALL
    Java_com_wuye_watermark_Watermark_extractingWatermark(JNIEnv *env, jclass instance, jstring _src, jstring _dst)
{
    const char *src = env->GetStringUTFChars(_src, nullptr);
    const char *dst = env->GetStringUTFChars(_dst, nullptr);

    std::string str = extractingWatermark(src, dst);
    if (str.empty())
    {
        return 1;
    }
    return 0;
}