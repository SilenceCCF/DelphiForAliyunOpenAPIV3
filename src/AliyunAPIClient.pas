unit AliyunAPIClient;
//
// 单元名称: AliyunAPIClient
// 功能描述: 提供了在不依赖官方SDK的情况下，调用阿里云OpenAPI V3规范接口的功能。
//           支持 GET, POST (application/json), POST (application/x-www-form-urlencoded),
//           以及文件上传 (application/octet-stream 等) 多种请求方式。
// 主要特点: 遵循 ACS3-HMAC-SHA256 签名算法。
//           为每个请求创建独立的HTTP客户端实例，确保线程安全和请求隔离。
//           包含完整的错误处理和资源管理机制。
//

interface

uses
  System.SysUtils, System.Classes, System.Hash, System.NetEncoding,
  System.Generics.Collections, DateUtils, System.Net.HttpClient,
  System.Net.URLClient, System.Net.HttpClientComponent;

type
  /// <summary>
  /// 封装阿里云API调用的响应结果。
  /// </summary>
  TAliyunAPIResponse = record
  public
    Success: Boolean;
    StatusCode: Integer;
    Content: string;
    ErrorMessage: string;
    class function Create(ASuccess: Boolean; AStatusCode: Integer; AContent, AErrorMessage: string): TAliyunAPIResponse; static;
  end;

  /// <summary>
  /// 阿里云API客户端类。
  /// </summary>
  TAliyunAPIClient = class
  private
    { 私有字段 }
    FAccessKeyId: string;
    FAccessKeySecret: string;
    FHeaders: TDictionary<string, string>;
    FQueryParams: TDictionary<string, string>;
    { 内部私有方法 }
    /// <summary>
    /// 生成符合ACS3-HMAC-SHA256规范的最终签名。
    /// </summary>
    function GenerateSignature(const HttpMethod, CanonicalURI, HashedRequestPayload: string; out SignedHeaders: string): string;
    /// <summary>
    /// 准备构建请求所需的头部信息，并存入 FHeaders 字典。
    /// </summary>
    procedure PrepareHeaders(const Host, XAcsAction, XAcsVersion, AHashedPayload, AContentType: string);
    /// <summary>
    /// 计算字符串的SHA256哈希值（十六进制小写）。
    /// </summary>
    function SHA256Hex(const AData: string): string; overload;
    /// <summary>
    /// 计算二进制数据的SHA256哈希值（十六进制小写）。
    /// </summary>
    function SHA256Hex(const ABytes: TBytes): string; overload;
    /// <summary>
    /// 计算HMAC-SHA256签名（十六进制小写）。
    /// </summary>
    function HMACSHA256Base16(const AKey, AData: string): string;
    /// <summary>
    /// 生成规范化的请求头字符串（Canonical Headers），用于签名。
    /// </summary>
    function GenerateCanonicalHeaders(out SignedHeaders: string): string;
    /// <summary>
    /// 生成规范化的查询字符串（Canonical Query String），用于签名。
    /// </summary>
    function GenerateCanonicalQueryString: string;
    /// <summary>
    /// 将传入的 TStringList 参数准备到 FQueryParams 字典中。
    /// </summary>
    procedure PrepareQueryParams(const QueryParams: TStringList);
    /// <summary>
    /// 构建最终的请求URL（包含Host, Path和查询参数）。
    /// </summary>
    function BuildRequestURL(const Host, CanonicalURI: string): string;

  public
    /// <summary>
    /// 构造函数。
    /// </param>
    /// <param name="AccessKeyId">AccessKey ID。</param>
    /// <param name="AccessKeySecret">AccessKey Secret。</param>
    constructor Create(const AccessKeyId, AccessKeySecret: string);
    /// <summary>
    /// 析构函数。
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    /// 执行 POST 请求。用于 Body 为 JSON 或其他自定义字符串的场景。
    /// </summary>
    /// <param name="Host">API服务的域名，例如 ecs.aliyuncs.com。</param>
    /// <param name="Action">API的接口名称，例如 CreateInstance。</param>
    /// <param name="Version">API的版本号，例如 2014-05-26。</param>
    /// <param name="QueryParams">URL查询参数（可选）。</param>
    /// <param name="RequestBody">请求体字符串，例如一个JSON字符串。</param>
    /// <param name="ContentType">请求体的内容类型，例如 application/json;charset=utf-8。</param>
    /// <returns>服务器返回的响应结果。</returns>
    function ExecutePOST(const Host, Action, Version: string; const QueryParams: TStringList = nil; const RequestBody: string = ''; const ContentType: string = ''): TAliyunAPIResponse;
    /// <summary>
    /// 以 POST 方式上传文件。
    /// </summary>
    /// <param name="Host">API服务的域名。</param>
    /// <param name="Action">API的接口名称。</param>
    /// <param name="Version">API的版本号。</param>
    /// <param name="QueryParams">URL查询参数，可用于传递文件元数据（可选）。</param>
    /// <param name="FilePath">要上传的本地文件的完整路径。</param>
    /// <param name="ContentType">文件的MIME类型，默认为 application/octet-stream。</param>
    /// <returns>服务器返回的响应结果。</returns>
    function ExecuteFilePOST(const Host, Action, Version: string; const QueryParams: TStringList; const FilePath: string; const ContentType: string = 'application/octet-stream'): TAliyunAPIResponse;
    /// <summary>
    /// 执行 POST 请求，参数格式为 application/x-www-form-urlencoded。
    /// 适用于 API 参数 "in" 定义为 "formData" 的情况。
    /// </summary>
    /// <param name="Host">API服务的域名。</param>
    /// <param name="Action">API的接口名称。</param>
    /// <param name="Version">API的版本号。</param>
    /// <param name="FormData">要提交的表单数据。</param>
    /// <returns>服务器返回的响应结果。</returns>
    function ExecuteFormDataPOST(const Host, Action, Version: string; const FormData: TStringList): TAliyunAPIResponse;
    /// <summary>
    /// 执行 GET 请求。适用于 API 参数 "in" 定义为 "query" 的情况。
    /// </summary>
    /// <param name="Host">API服务的域名。</param>
    /// <param name="Action">API的接口名称。</param>
    /// <param name="Version">API的版本号。</param>
    /// <param name="QueryParams">URL查询参数。</param>
    /// <returns>服务器返回的响应结果。</returns>
    function ExecuteGET(const Host, Action, Version: string; const QueryParams: TStringList = nil): TAliyunAPIResponse;
    /// <summary>
    /// 类方法，用于创建一个符合单元要求的 TStringList 实例。
    /// </summary>
    class function CreateParams: TStringList; static;
    /// <summary>
    /// 获取上一次请求的详细信息，用于调试目的。
    /// </summary>
    function GetLastRequestInfo: string;
  end;

const
  // 阿里云V3签名算法常量
  ALGORITHM = 'ACS3-HMAC-SHA256';
  // 表单提交的内容类型常量
  CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';

implementation

uses
  System.IOUtils;

// *** TAliyunAPIResponse 的实现 ***
class function TAliyunAPIResponse.Create(ASuccess: Boolean; AStatusCode: Integer; AContent, AErrorMessage: string): TAliyunAPIResponse;
begin
  Result.Success := ASuccess;
  Result.StatusCode := AStatusCode;
  Result.Content := AContent;
  Result.ErrorMessage := AErrorMessage;
end;

constructor TAliyunAPIClient.Create(const AccessKeyId, AccessKeySecret: string);
begin
  inherited Create;
  FAccessKeyId := AccessKeyId;
  FAccessKeySecret := AccessKeySecret;
  FHeaders := TDictionary<string, string>.Create;
  FQueryParams := TDictionary<string, string>.Create;
end;

destructor TAliyunAPIClient.Destroy;
begin
  FHeaders.Free;
  FQueryParams.Free;
  inherited Destroy;
end;

function TAliyunAPIClient.SHA256Hex(const AData: string): string;
begin
  Result := LowerCase(THashSHA2.GetHashString(AData, THashSHA2.TSHA2Version.SHA256));
end;

function TAliyunAPIClient.SHA256Hex(const ABytes: TBytes): string;
var
  InputStream: TBytesStream;
begin
  InputStream := TBytesStream.Create(ABytes);
  try
    Result := LowerCase(THashSHA2.GetHashString(InputStream, THashSHA2.TSHA2Version.SHA256));
  finally
    InputStream.Free;
  end;
end;

function TAliyunAPIClient.HMACSHA256Base16(const AKey, AData: string): string;
var
  HashBytes: TBytes;
begin
  HashBytes := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(AData), TEncoding.UTF8.GetBytes(AKey), SHA256);
  Result := '';
  for var I in HashBytes do
    Result := Result + I.ToHexString(2).ToLower;
end;

function TAliyunAPIClient.GenerateCanonicalHeaders(out SignedHeaders: string): string;
var
  Keys: TStringList;
  Key, LowerKey: string;
begin
  Keys := TStringList.Create;
  try
    for Key in FHeaders.Keys do
    begin
      LowerKey := Key.ToLower;
      if LowerKey.StartsWith('x-acs-') or (LowerKey = 'host') or (LowerKey = 'content-type') then
        Keys.Add(LowerKey);
    end;
    Keys.Sort;
    SignedHeaders := StringReplace(Keys.Text, sLineBreak, ';', [rfReplaceAll, rfIgnoreCase]);
    if SignedHeaders.EndsWith(';') then
      Delete(SignedHeaders, Length(SignedHeaders), 1);
    Result := '';
    for Key in Keys do
      for var HeaderKey in FHeaders.Keys do
        if HeaderKey.ToLower = Key then
        begin
          Result := Result + Key + ':' + Trim(FHeaders[HeaderKey]) + #10;
          Break;
        end;
  finally
    Keys.Free;
  end;
end;

function TAliyunAPIClient.GenerateCanonicalQueryString: string;
var
  Pairs: TStringList;
begin
  Pairs := TStringList.Create;
  try
    for var Key in FQueryParams.Keys do
      Pairs.Add(TNetEncoding.URL.Encode(Key) + '=' + TNetEncoding.URL.Encode(FQueryParams[Key]));
    Pairs.Sort;
    Result := StringReplace(Pairs.Text, sLineBreak, '&', [rfReplaceAll]);
    if Result.EndsWith('&') then
      Delete(Result, Length(Result), 1);
  finally
    Pairs.Free;
  end;
end;

function TAliyunAPIClient.GenerateSignature(const HttpMethod, CanonicalURI, HashedRequestPayload: string; out SignedHeaders: string): string;
var
  CanonicalHeaders, CanonicalRequest, HashedCanonicalRequest, StringToSign, CanonicalQueryString: string;
begin
  CanonicalHeaders := GenerateCanonicalHeaders(SignedHeaders);
  CanonicalQueryString := GenerateCanonicalQueryString;
  CanonicalRequest := HttpMethod + #10 + CanonicalURI + #10 + CanonicalQueryString + #10 + CanonicalHeaders + #10 + SignedHeaders + #10 + HashedRequestPayload;
  HashedCanonicalRequest := SHA256Hex(CanonicalRequest);
  StringToSign := ALGORITHM + #10 + HashedCanonicalRequest;
  Result := LowerCase(HMACSHA256Base16(FAccessKeySecret, StringToSign));
end;

procedure TAliyunAPIClient.PrepareHeaders(const Host, XAcsAction, XAcsVersion, AHashedPayload, AContentType: string);
begin
  FHeaders.Clear;
  FHeaders.Add('host', Host);
  FHeaders.Add('x-acs-action', XAcsAction);
  FHeaders.Add('x-acs-version', XAcsVersion);
  FHeaders.Add('x-acs-date', FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"Z"', TTimeZone.local.ToUniversalTime(Now)));
  FHeaders.Add('x-acs-signature-nonce', TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '').ToLower);
  FHeaders.Add('x-acs-content-sha256', AHashedPayload);
  if not AContentType.IsEmpty then
    FHeaders.Add('Content-Type', AContentType);
end;

procedure TAliyunAPIClient.PrepareQueryParams(const QueryParams: TStringList);
begin
  FQueryParams.Clear;
  if Assigned(QueryParams) then
    for var i := 0 to QueryParams.Count - 1 do
      FQueryParams.Add(QueryParams.Names[i], QueryParams.ValueFromIndex[i]);
end;

function TAliyunAPIClient.BuildRequestURL(const Host, CanonicalURI: string): string;
var
  QueryString: string;
begin
  Result := 'https://' + Host + CanonicalURI;
  QueryString := GenerateCanonicalQueryString;
  if QueryString <> '' then
    Result := Result + '?' + QueryString;
end;

function TAliyunAPIClient.ExecuteGET(const Host, Action, Version: string; const QueryParams: TStringList): TAliyunAPIResponse;
var
  HttpClient: TNetHTTPClient;
  Resp: IHTTPResponse;
  URL, HashedPayload, HttpMethod, Signature, SignedHeaders, AuthHeader: string;
begin
  HttpClient := TNetHTTPClient.Create(nil);
  try
    HttpMethod := 'GET';
    HashedPayload := SHA256Hex('');

    PrepareQueryParams(QueryParams);
    PrepareHeaders(Host, Action, Version, HashedPayload, '');

    Signature := GenerateSignature(HttpMethod, '/', HashedPayload, SignedHeaders);
    AuthHeader := Format('%s Credential=%s,SignedHeaders=%s,Signature=%s', [ALGORITHM, FAccessKeyId, SignedHeaders, Signature]);
    FHeaders.Add('Authorization', AuthHeader);

    for var Pair in FHeaders do
      HttpClient.CustomHeaders[Pair.Key] := Pair.Value;

    URL := BuildRequestURL(Host, '/');
    // 执行请求
    Resp := HttpClient.Get(URL);
    // 根据HTTP状态码判断成功或失败
    if (Resp.StatusCode >= 200) and (Resp.StatusCode <= 299) then
      Result := TAliyunAPIResponse.Create(True, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), '')
    else
      Result := TAliyunAPIResponse.Create(False, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), Format('HTTP请求失败，状态码: %d - %s', [Resp.StatusCode, Resp.StatusText]));
  except
    on E: Exception do
      // 如果发生网络层异常，Resp为空，我们在这里处理
      Result := TAliyunAPIResponse.Create(False, -1, '', 'API 调用异常 (GET): ' + E.Message);
  end;
  // Free 总是最后执行
  HttpClient.Free;
end;

// *** POST方法的实现 ***
function TAliyunAPIClient.ExecutePOST(const Host, Action, Version: string; const QueryParams: TStringList; const RequestBody: string; const ContentType: string): TAliyunAPIResponse;
var
  HttpClient: TNetHTTPClient;
  Resp: IHTTPResponse;
  RequestStream: TStringStream;
  URL, HashedPayload, HttpMethod, Signature, SignedHeaders, AuthHeader: string;
begin
  HttpClient := TNetHTTPClient.Create(nil);
  try
    HttpMethod := 'POST';
    HashedPayload := SHA256Hex(RequestBody);
    PrepareQueryParams(QueryParams);
    PrepareHeaders(Host, Action, Version, HashedPayload, ContentType);
    Signature := GenerateSignature(HttpMethod, '/', HashedPayload, SignedHeaders);
    AuthHeader := Format('%s Credential=%s,SignedHeaders=%s,Signature=%s', [ALGORITHM, FAccessKeyId, SignedHeaders, Signature]);
    FHeaders.Add('Authorization', AuthHeader);
    for var Pair in FHeaders do
      HttpClient.CustomHeaders[Pair.Key] := Pair.Value;
    URL := BuildRequestURL(Host, '/');
    RequestStream := TStringStream.Create(RequestBody, TEncoding.UTF8);
    try
      Resp := HttpClient.Post(URL, RequestStream);
    finally
      RequestStream.Free;
    end;
    if (Resp.StatusCode >= 200) and (Resp.StatusCode <= 299) then
      Result := TAliyunAPIResponse.Create(True, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), '')
    else
      Result := TAliyunAPIResponse.Create(False, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), Format('HTTP请求失败，状态码: %d - %s', [Resp.StatusCode, Resp.StatusText]));
  except
    on E: Exception do
      Result := TAliyunAPIResponse.Create(False, -1, '', 'API 调用异常 (POST): ' + E.Message);
  end;
  HttpClient.Free;
end;

// *** FilePOST方法的实现 ***
function TAliyunAPIClient.ExecuteFilePOST(const Host, Action, Version: string; const QueryParams: TStringList; const FilePath: string; const ContentType: string): TAliyunAPIResponse;
var
  HttpClient: TNetHTTPClient;
  Resp: IHTTPResponse;
  FileStream: TFileStream;
  FileBytes: TBytes;
  URL, HashedPayload, HttpMethod, Signature, SignedHeaders, AuthHeader: string;
begin
  if not TFile.Exists(FilePath) then
  begin
    Result := TAliyunAPIResponse.Create(False, -1, '', '文件未找到: ' + FilePath);
    Exit;
  end;
  HttpClient := TNetHTTPClient.Create(nil);
  try
    FileBytes := TFile.ReadAllBytes(FilePath);
    HashedPayload := SHA256Hex(FileBytes);
    HttpMethod := 'POST';
    PrepareQueryParams(QueryParams);
    PrepareHeaders(Host, Action, Version, HashedPayload, ContentType);
    Signature := GenerateSignature(HttpMethod, '/', HashedPayload, SignedHeaders);
    AuthHeader := Format('%s Credential=%s,SignedHeaders=%s,Signature=%s', [ALGORITHM, FAccessKeyId, SignedHeaders, Signature]);
    FHeaders.Add('Authorization', AuthHeader);
    for var Pair in FHeaders do
      HttpClient.CustomHeaders[Pair.Key] := Pair.Value;
    URL := BuildRequestURL(Host, '/');
    FileStream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyWrite);
    try
      Resp := HttpClient.Post(URL, FileStream);
    finally
      FileStream.Free;
    end;
    if (Resp.StatusCode >= 200) and (Resp.StatusCode <= 299) then
      Result := TAliyunAPIResponse.Create(True, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), '')
    else
      Result := TAliyunAPIResponse.Create(False, Resp.StatusCode, Resp.ContentAsString(TEncoding.UTF8), Format('HTTP请求失败，状态码: %d - %s', [Resp.StatusCode, Resp.StatusText]));
  except
    on E: Exception do
      Result := TAliyunAPIResponse.Create(False, -1, '', 'API 调用异常 (File POST): ' + E.Message);
  end;
  HttpClient.Free;
end;

function TAliyunAPIClient.ExecuteFormDataPOST(const Host, Action, Version: string; const FormData: TStringList): TAliyunAPIResponse;
var
  RequestBody: string;
  sb: TStringBuilder;
begin
  sb := TStringBuilder.Create;
  try
    if Assigned(FormData) then
      for var i := 0 to FormData.Count - 1 do
      begin
        if i > 0 then
          sb.Append('&');
        sb.Append(TNetEncoding.URL.Encode(FormData.Names[i]));
        sb.Append('=');
        sb.Append(TNetEncoding.URL.Encode(FormData.ValueFromIndex[i]));
      end;
    RequestBody := sb.ToString;
  finally
    sb.Free;
  end;
  Result := ExecutePOST(Host, Action, Version, nil, RequestBody, CONTENT_TYPE_FORM);
end;

class function TAliyunAPIClient.CreateParams: TStringList;
begin
  Result := TStringList.Create;
  Result.NameValueSeparator := '=';
end;

function TAliyunAPIClient.GetLastRequestInfo: string;
var
  Pair: TPair<string, string>;
begin
  Result := '=== 请求信息 ===' + sLineBreak;
  Result := Result + 'Query参数:' + sLineBreak;
  if FQueryParams.Count > 0 then
    for Pair in FQueryParams do
      Result := Result + Format('  %s = %s', [Pair.Key, Pair.Value]) + sLineBreak
  else
    Result := Result + '  (无)' + sLineBreak;
  Result := Result + sLineBreak + '请求头:' + sLineBreak;
  if FHeaders.Count > 0 then
    for Pair in FHeaders do
      Result := Result + Format('  %s: %s', [Pair.Key, Pair.Value]) + sLineBreak
  else
    Result := Result + '  (无)' + sLineBreak;
end;

end.
