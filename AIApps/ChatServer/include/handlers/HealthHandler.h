#pragma once
#include "../../../HttpServer/include/http/HttpRequest.h"
#include "../../../HttpServer/include/http/HttpResponse.h"

class HealthHandler : public http::router::RouterHandler
{
public:
    void handle(const http::HttpRequest& req, http::HttpResponse* resp) override;
};
