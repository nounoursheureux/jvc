#include <tinyxml.h>
#include <curl/curl.h>
#include <iostream>
#include <unistd.h>
#include <pwd.h>
#include <algorithm>

size_t write_data(void* buffer, size_t size, size_t nmemb, FILE* userp);
void topic_list(std::string path,std::string forum_number);
void author(std::string author,std::string path,std::string forum_number);
void search(std::string search,std::string path,std::string forum_number);
void download(std::string url,std::string path);
