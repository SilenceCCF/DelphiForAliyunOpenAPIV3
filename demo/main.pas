unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Vcl.ExtCtrls, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, AliyunAPIClient, System.IOUtils;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ButtonExit: TButton;
    ButtonGet: TButton;
    ButtonPostNoBody: TButton;
    ButtonBodyWithJson: TButton;
    ButtonBodyWithFormData: TButton;
    ButtonBodyUpload: TButton;
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonGetClick(Sender: TObject);
    procedure ButtonPostNoBodyClick(Sender: TObject);
    procedure ButtonBodyWithJsonClick(Sender: TObject);
    procedure ButtonBodyWithFormDataClick(Sender: TObject);
    procedure ButtonBodyUploadClick(Sender: TObject);
    procedure ProcessResponse(Response: TAliyunAPIResponse; RequestInfo: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  AccessKeyId = '你的 ID';
  AccessKeySecret = '你的 Secret';

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ProcessResponse(Response: TAliyunAPIResponse; RequestInfo: string);
begin
  //处理请求返回消息
  // 显示请求详情（可选，用于调试）
  Memo1.Lines.Add(RequestInfo);   // 判断成功或失败
  if Response.Success then
  begin
    Memo1.Lines.Add('API调用成功！');
    Memo1.Lines.Add('HTTP状态码: ' + Response.StatusCode.ToString);
    Memo1.Lines.Add('响应内容:');
    Memo1.Lines.Add(Response.Content);
  end
  else
  begin
    Memo1.Lines.Add('API调用失败！');
    Memo1.Lines.Add('错误信息: ' + Response.ErrorMessage);
    Memo1.Lines.Add('HTTP状态码: ' + Response.StatusCode.ToString);
    Memo1.Lines.Add('服务器原始响应:');
    Memo1.Lines.Add(Response.Content);
  end;
end;

procedure TForm1.ButtonGetClick(Sender: TObject);
var
  Response: TAliyunAPIResponse;
  APIClient: TAliyunAPIClient;
  params: TStringList;
begin
  // 创建API客户端
  APIClient := TAliyunAPIClient.Create(AccessKeyId, AccessKeySecret);
  Memo1.Clear;
  Memo1.Lines.Add('正在使用 GET 方法查询域名列表...');
  try
    params := TStringList.Create;
    params.Values['PageNum'] := '1';
    params.Values['PageSize'] := '100';
    // 查询域名列表
    Response := APIClient.ExecuteGET('domain.aliyuncs.com', 'QueryDomainList', '2018-01-29', params);
    params.Free;
    ProcessResponse(Response, APIClient.GetLastRequestInfo);
  finally
    APIClient.Free;
  end;
end;

procedure TForm1.ButtonBodyWithJsonClick(Sender: TObject);
// 2. POST 请求 - Body 为 JSON（参数 "in": "body"）
// 适用于创建、修改等操作，参数结构复杂，通过JSON传递。
var
  APIClient: TAliyunAPIClient;
  JsonBody: string;
  Response: TAliyunAPIResponse;
begin
  APIClient := TAliyunAPIClient.Create(AccessKeyId, AccessKeySecret);
  Memo1.Clear;
  Memo1.Lines.Add('正在使用在 body 中添加 json 字符串的方法操作...');
  try
    // 示例：创建一个ECS实例（仅为演示，参数不完整）
    // 实际使用时，请根据API文档构建完整的JSON
    JsonBody := '{"RegionId":"cn-hangzhou","ImageId":"aliyun_3_x64_20G_alibase_20210924.vhd","InstanceType":"ecs.g6.large"}';
    // 调用ExecutePOST，传入JSON字符串和对应的Content-Type
    // 此时通常没有Query参数 (QueryParams = nil)
    Response := APIClient.ExecutePOST('ecs.aliyuncs.com', 'CreateInstance', '2014-05-26', nil, JsonBody, 'application/json;charset=utf-8');
    ProcessResponse(Response, APIClient.GetLastRequestInfo);
  finally
    APIClient.Free;
  end;
end;

procedure TForm1.ButtonBodyWithFormDataClick(Sender: TObject);
// POST 请求 - Body 为 FormData（参数 "in": "formData"）
// 类似于网页表单提交，通常用于简单的修改操作。
var
  ApiClient: TAliyunAPIClient;
  FormData: TStringList;
  Response: TAliyunAPIResponse;
begin
  ApiClient := TAliyunAPIClient.Create(AccessKeyId, AccessKeySecret);
  FormData := TAliyunAPIClient.CreateParams;
  try
    FormData.AddPair('SubDomain', 'test.domain.com');
    FormData.AddPair('Type', 'A');
    // 调用 ExecuteFormDataPOST
    Response := ApiClient.ExecuteFormDataPOST('dns.aliyuncs.com', 'DescribeSubDomainRecords', '2015-01-09', FormData);
    ProcessResponse(Response, ApiClient.GetLastRequestInfo);
  finally
    FormData.Free;
    ApiClient.Free;
  end;
end;

procedure TForm1.ButtonBodyUploadClick(Sender: TObject);
// 4. POST 请求 - 上传文件（参数 "in": "body"，流式）
// 适用于需要上传二进制文件的场景，例如上传到OSS（对象存储）或其它接收文件的服务。
var
  ApiClient: TAliyunAPIClient;
  Response: TAliyunAPIResponse;
  FilePath: string;
begin
  ApiClient := TAliyunAPIClient.Create(AccessKeyId, AccessKeySecret);
  try
    // 准备一个用于上传的本地文件
    FilePath := 'e:\temp\test.txt';
    if not TFile.Exists(FilePath) then
    begin
      ShowMessage('测试文件不存在: ' + FilePath);
      Exit;
    end;

    // 示例：调用一个虚构的“上传”接口
    // 注意：Host, Action, Version都需要根据实际API文档填写
    // 某些API可能还需要通过Query参数传递元数据
    Response := ApiClient.ExecuteFilePOST('your-service.aliyuncs.com', // 替换为实际服务的Host
      'UploadFile',                  // 替换为实际的Action
      '2022-01-01',                  // 替换为实际的Version
      nil,                           // 如果需要，可以传递Query参数
      FilePath,                      // 要上传的文件的完整路径
      'application/pdf'              // 文件的MIME类型，必须指定
    );
    ProcessResponse(Response, ApiClient.GetLastRequestInfo);
  finally
    ApiClient.Free;
  end;
end;

procedure TForm1.ButtonExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.ButtonPostNoBodyClick(Sender: TObject);
var
  Response: TAliyunAPIResponse;
  APIClient: TAliyunAPIClient;
  params: TStringList;
begin
  // 通过 POST 方式查询：
  // API的请求参数为 "in":"query" 方式，此时 POST 数据中的 body 为空，
  // 对应的 x-acs-content-sha256 为固定值：
  // e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
  // ContentType 也可以不填。
  // 创建API客户端
  APIClient := TAliyunAPIClient.Create(AccessKeyId, AccessKeySecret);
  Memo1.Clear;
  Memo1.Lines.Add('查询域名解析地址...');
  try
    params := TStringList.Create;
    params.AddPair('SubDomain', 'test.domain.com');
    params.AddPair('Type', 'A');
    // RequestBody 和 ContentType 都为空，最后两个参数可以省略。
    Response := APIClient.ExecutePOST('dns.aliyuncs.com', 'DescribeSubDomainRecords', '2015-01-09', params, '', '');
    params.Free;
    ProcessResponse(Response, APIClient.GetLastRequestInfo);
  finally
    APIClient.Free;
  end;
end;

end.
