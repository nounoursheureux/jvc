#include "jvc.h"

int main(int argc,char* argv[])
{
    struct passwd* pw = getpwuid(getuid());
    std::string home = pw->pw_dir;
    std::string path = home + "/.jvc/topics.xml";
    std::string forum_number;
    if(strcmp(argv[1],"linux") == 0) forum_number = "38";
    if(argc < 3) topic_list(path,forum_number);
    else if(!strcmp(argv[2],"author")) author(argv[3],path,forum_number);
    else if(!strcmp(argv[2],"search")) search(argv[3],path,forum_number);
    return 0;
}

size_t write_data(void* ptr, size_t size, size_t nmemb, FILE* userp)
{
    size_t written = fwrite(ptr,size,nmemb,userp);
    return written; 
}

void topic_list(std::string path,std::string forum_number)
{
    FILE* fp;
    CURL* handle = curl_easy_init();
    std::string url = "http://ws.jeuxvideo.com/forums/0-" + forum_number + "-0-1-0-1-0-0.xml";
    download(url,path);
    TiXmlDocument doc(path);
    doc.LoadFile();
    TiXmlElement* elem = doc.FirstChildElement()->FirstChildElement("topic");
    while(elem)
    {
        std::cout << elem->FirstChildElement("auteur")->GetText() << " : " << elem->FirstChildElement("titre")->GetText() << std::endl;
        elem = elem->NextSiblingElement();
    }
}

void author(std::string author,std::string path,std::string forum_number)
{
    std::transform(author.begin(),author.end(),author.begin(),::tolower);
    std::string url = "http://ws.jeuxvideo.com/forums/0-" + forum_number + "-0-1-0-1-1-" + author + ".xml";
    download(url,path);
    TiXmlDocument doc(path);
    doc.LoadFile();
    TiXmlElement* elem = doc.FirstChildElement()->FirstChildElement("topic");
    while(elem)
    {
        std::cout << elem->FirstChildElement("titre")->GetText() << std::endl;
        elem = elem->NextSiblingElement();
    }
}

void search(std::string search,std::string path,std::string forum_number)
{
    std::transform(search.begin(),search.end(),search.begin(),::tolower);   
    std::string url = "http://ws.jeuxvideo.com/forums/0-" + forum_number + "-0-1-0-1-2-" + search + ".xml";
    download(url,path);
    TiXmlDocument doc(path);
    doc.LoadFile();
    TiXmlElement* elem = doc.FirstChildElement()->FirstChildElement("topic");
    while(elem)
    {
        std::cout << elem->FirstChildElement("auteur")->GetText() << " : " << elem->FirstChildElement("titre")->GetText() << std::endl;
        elem = elem->NextSiblingElement();
    }
}

void download(std::string url,std::string path)
{
    FILE* fp;
    CURL* handle = curl_easy_init();
    if(handle)
    {
        fp = fopen(path.c_str(),"wb");
        curl_easy_setopt(handle,CURLOPT_URL,url.c_str());
        curl_easy_setopt(handle,CURLOPT_USERNAME,"app_and_gnw");
        curl_easy_setopt(handle,CURLOPT_PASSWORD,"FC?4554?");
        curl_easy_setopt(handle,CURLOPT_WRITEFUNCTION,write_data);
        curl_easy_setopt(handle,CURLOPT_WRITEDATA,fp);
        CURLcode success = curl_easy_perform(handle);
        curl_easy_cleanup(handle);
        fclose(fp);
    }
    
}
