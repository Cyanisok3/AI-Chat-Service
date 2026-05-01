#include "../include/handlers/ChatEntryHandler.h"



void ChatEntryHandler::handle(const http::HttpRequest& req, http::HttpResponse* resp)
{
    // 因为是get请求，请求的url也拿到了，我们就可以直接返回响应了

    // 绝对路径
    std::string reqFile = "/project/AIApps/ChatServer/resource/entry.html";
    FileUtil fileOperater(reqFile);
    if (!fileOperater.isValid())
    {
        LOG_WARN << reqFile << " not exist";
        fileOperater.resetDefaultFile(); // 404 NOT FOUND
    }

    std::vector<char> buffer(fileOperater.size());
    fileOperater.readFile(buffer); // 读出文件数据
    std::string bufStr = std::string(buffer.data(), buffer.size());

    resp->setStatusLine(req.getVersion(), http::HttpResponse::k200Ok, "OK");
    resp->setCloseConnection(false);
    resp->setContentType("text/html");
    resp->setContentLength(bufStr.size());
    resp->setBody(bufStr);
}
