<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PLI_CJHS.aspx.cs" Inherits="PLI.PLI_CJHS" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>廠外管線巡檢系統</title>
    <link rel="apple-touch-icon" href="pic/formosa-144.png" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <link type="text/css" rel="stylesheet" media="screen and (max-width: 1024px)" href="css/CJHS-1024-max-device.css" />
    <link type="text/css" rel="stylesheet" media="screen and (min-width: 1025px)" href="css/CJHS-1025-min-device.css" />
    <script type="text/javascript" src="js/jquery-1.8.2.js"></script>
    <script type="text/javascript" src="js/BlockUI.js"></script>
    <script type="text/javascript" src="js/minwt.auto_full_height.mini.js"></script>
    <script type="text/javascript">
        function GetGPS() {
            if (navigator.geolocation) {
                // HTML5 定位抓取
                navigator.geolocation.getCurrentPosition(
                function (position) {
                    mapServiceProvider(position.coords.latitude, position.coords.longitude);
                },
                function (error) {
                    switch (error.code) {
                        case error.TIMEOUT:
                            //alert('連線逾時');
                            break;
                        case error.POSITION_UNAVAILABLE:
                            //alert('無法取得定位');
                            break;
                        case error.PERMISSION_DENIED: //拒絕  
                            //alert('尚未開啟定位');
                            break;
                        case error.UNKNOWN_ERROR:
                            //alert('不明的錯誤，請稍候再試');
                            break;
                    }
                });
            }
            else {
                // 不支援 HTML5 定位    
                // 若支援 Google Gears   
                if (window.google && google.gears) {
                    try {
                        // 嘗試以 Gears 取得定位         
                        var geo = google.gears.factory.create('beta.geolocation');
                        geo.getCurrentPosition(
                            successCallback,
                            errorCallback,
                            {
                                enableHighAccuracy: true,
                                gearsRequestAddress: true
                            });
                    }
                    catch (e) {
                        //alert("定位失敗請稍候再試");
                    }
                }
                else {
                    //alert("尚未開啟定位");
                }
            }

            // 取得 Gears 定位發生錯誤
            function errorCallback(err) {
                var msg = 'Error retrieving your location: ' + err.message;
                alert(msg);
            }
            // 成功取得 Gears 定位
            function successCallback(p) {
                mapServiceProvider(p.latitude, p.longitude);
            }
            // 顯示經緯度 
            function mapServiceProvider(latitude, longitude) {
                document.getElementById("latitude").value = latitude;
                document.getElementById("longitude").value = longitude;
            }
        }
        function loading() {
            $.blockUI({
                message: $('<h3 style="text-align:center"><img src="pic/please_wait.gif" /><br/>檔案上傳中...請稍後...</h3>'),
                css: {
                    top: '45%',
                    left: '35%',
                    '-webkit-border-radius': '10px',
                    '-moz-border-radius': '10px',
                    opacity: 0.8,
                    color: '#000'
                }
            });
        }
    </script>
</head>
<body style="background-color: #f2f2f2;">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager" runat="server">
    </asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
        <Triggers>
            <asp:PostBackTrigger ControlID="PhotoBtn" />
            <asp:AsyncPostBackTrigger ControlID="Timer1" EventName="Tick" />
        </Triggers>
        <ContentTemplate>
            <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0">
                <asp:View ID="View1" runat="server">
                    <div style="text-align: center;">
                        <table class="LoginTop" style="width: 100%;">
                            <tr>
                                <td>
                                    <asp:Image ID="LoginImg" runat="server" ImageUrl="pic/logo-fpg.png" />
                                </td>
                            </tr>
                            <tr>
                                <td class="LoginTop">
                                    <asp:Label ID="Login1Lb" runat="server" Text="長途地下管線巡查紀錄表" CssClass="login"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="Login2Lb" runat="server" Text="巡檢紀錄表" CssClass="login"></asp:Label>
                                </td>
                            </tr>
                        </table>
                        <table style="width: 100%;">
                            <tr>
                                <td align="center">
                                    <table class="LoginTop">
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="Label1" runat="server" Text="NOTES ID" CssClass="font-medium"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="LoginBtn">
                                                <asp:TextBox ID="AccountTb" runat="server" CssClass="font2" Width="250px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="Label2" runat="server" Text="密碼" CssClass="font-medium"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="LoginBtn">
                                                <asp:TextBox ID="PasswordTb" runat="server" TextMode="Password" CssClass="font2"
                                                    Width="250px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="Label5" runat="server" Text="網域" CssClass="font-medium"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="LoginBtn">
                                                <asp:DropDownList ID="DomainDdl" runat="server" CssClass="font2" Width="255px">
                                                    <asp:ListItem Value="tw.fpg.com">TWFPG</asp:ListItem>
                                                    <asp:ListItem Value="fpccmtn.tw.fpg.com">FPCCMTN</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Button ID="LoginBtn" runat="server" Text="登入" OnClick="LoginBtn_Click" CssClass="LoginButton"
                                                    Style="text-align: center;" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </asp:View>
                <asp:View ID="View2" runat="server">
                    <div style="background-color: #f2f2f2; height: 100%;">
                        <table width="100%" style="background-color: #0f6fc6; border-collapse: collapse;">
                            <tr>
                                <td align="center" valign="middle" style="width: 100px;">
                                    <asp:Button ID="SendBtn" runat="server" Text="呈核" OnClick="SendBtn_Click" CssClass="font2"
                                        OnClientClick="this.disabled=true;" UseSubmitBehavior="False" />
                                </td>
                                <td align="center">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Image ID="logo" runat="server" ImageUrl="pic/logo-fpc.png" />
                                            </td>
                                            <td>
                                                <asp:Label ID="PLI_CJHS_Title" runat="server" Text="長途地下管線巡查紀錄表" CssClass="title"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="center" valign="middle" style="width: 100px;">
                                    <asp:Button ID="LogoutBtn" runat="server" Text="登出" OnClick="LogoutBtn_Click" CssClass="font2" />
                                </td>
                            </tr>
                        </table>
                        <table width="100%" style="background-color: #7cca62;">
                            <tr>
                                <td align="center" valign="middle" style="padding: 0px 0px 0px 0px;">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Label ID="DateLb" runat="server" Text="巡檢日期：" CssClass="font2"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:DropDownList ID="DateDdl" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DateDdl_SelectedIndexChanged"
                                                    CssClass="font2">
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:Label ID="HumanLb" runat="server" Text="巡檢人員：" CssClass="font2"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:Label ID="HumanName" runat="server" CssClass="font2"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:Label ID="WeatherLb" runat="server" Text="天候：" CssClass="font2"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:DropDownList ID="WeatherDdl" runat="server" CssClass="font2" Style="background-color: #ffffff;">
                                                    <asp:ListItem>晴天</asp:ListItem>
                                                    <asp:ListItem>陰天</asp:ListItem>
                                                    <asp:ListItem>雨天</asp:ListItem>
                                                    <asp:ListItem>颱風</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <table style="margin: 0px auto;">
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Label ID="ValueLb" runat="server" CssClass="title1"></asp:Label>
                                            </td>
                                            <td align="right">
                                                <asp:Button ID="PreviousAreaBtn" runat="server" Text=" ＜ " OnClick="PreviousAreaBtn_Click"
                                                    CssClass="ArrowBtn" Style="margin-right: 5px;" />
                                                <asp:Button ID="NextAreaBtn" runat="server" Text=" ＞ " OnClick="NextAreaBtn_Click"
                                                    CssClass="ArrowBtn" Style="margin-right: 5px;" />
                                                <asp:Button ID="AllAreaBtn" runat="server" Text="檢視全區" OnClick="AllAreaBtn_Click"
                                                    CssClass="Button" Style="margin-right: 5px;" />
                                                <asp:Button ID="MapBtn" runat="server" Text="位置圖" OnClick="MapBtn_Click" CssClass="Button" />
                                            </td>
                                            <td valign="top" rowspan="2" class="PhotoTd" style="padding-left: 20px;">
                                                <table id="PhotoTable" runat="server">
                                                    <tr>
                                                        <td colspan="2" align="center" valign="middle" class="PhotoTable">
                                                            <div class="PhotoDiv">
                                                                <asp:DataList ID="PhotoDl" runat="server" RepeatDirection="Horizontal">
                                                                    <ItemTemplate>
                                                                        <table style="position: relative; top: 0px; z-index: 100;">
                                                                            <tr>
                                                                                <td>
                                                                                    <asp:Image ID="PhotoImg" runat="server" CssClass="Image" />
                                                                                    <asp:Button ID="DeleteBtn" runat="server" OnClientClick="return confirm('您確定要刪除嗎?')"
                                                                                        OnClick="DeleteBtn_Click" CssClass="DeleteBtn" Style="position: absolute; top: 1px;
                                                                                        right: 1px; background-image: url(pic/delete.png); z-index: 100;" />
                                                                                    <asp:TextBox ID="PhotoPidTb" runat="server" Text='<%# Bind("Pid") %>' Visible="false"></asp:TextBox>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:DataList>
                                                                <asp:Image ID="Photo2Img" runat="server" ImageUrl="pic/icon-camera.png" CssClass="Image" />
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style="padding: 5px 0px 0px 0px;">
                                                            <asp:FileUpload ID="PhotoFu" runat="server" CssClass="PhotoFu" />
                                                        </td>
                                                        <td style="padding: 5px 0px 0px 0px;">
                                                            <asp:Button ID="PhotoBtn" runat="server" Text="上傳" OnClientClick="loading();" OnClick="PhotoBtn_Click"
                                                                CssClass="PhotoBtn" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="left" style="padding-top: 5px;">
                                                            <asp:Label ID="Label3" runat="server" Text="異常項目及處理情形" CssClass="title2"></asp:Label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="center" style="padding-top: 5px;">
                                                            <asp:TextBox ID="ValueTb" runat="server" Rows="4" TextMode="MultiLine" CssClass="font2"
                                                                Style="width: 98%; overflow: auto;"></asp:TextBox>
                                                            <asp:TextBox ID="ValuePidTb" runat="server" Visible="false"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="center" style="height: 35px; padding-top: 5px;">
                                                            <asp:Button ID="SaveBtn" runat="server" Text="儲存" OnClick="SaveBtn_Click" CssClass="SaveButton" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" colspan="2">
                                                <asp:DataList ID="PLI_CJHS_Dl2" runat="server" RepeatColumns="4" RepeatDirection="Horizontal">
                                                    <ItemTemplate>
                                                        <table>
                                                            <tr>
                                                                <td colspan="3" style="padding-bottom: 5px; border-bottom: #0f6fc6 1px solid;">
                                                                    <asp:Label ID="GroundLb" runat="server" Text="地面目視巡查" CssClass="title2"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label6" runat="server" Text="管線表面包覆是否完整、無破損" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A01_True_Rb" runat="server" GroupName="A01" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A01_False_Rb" runat="server" GroupName="A01" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label7" runat="server" Text="地面是否異常凹陷" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A02_True_Rb" runat="server" GroupName="A02" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A02_False_Rb" runat="server" GroupName="A02" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label8" runat="server" Text="道路是否施工、開挖" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A03_True_Rb" runat="server" GroupName="A03" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A03_False_Rb" runat="server" GroupName="A03" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3" style="padding: 0px 0px  5px 0px; border-bottom: #0f6fc6 1px solid;">
                                                                    <asp:Label ID="RectifierLb" runat="server" Text="整流站巡查" CssClass="title2"></asp:Label>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label10" runat="server" Text="外部電源是否正常" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A04_True_Rb" runat="server" GroupName="A04" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A04_False_Rb" runat="server" GroupName="A04" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label11" runat="server" Text="箱體把手開關是否正常" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A05_True_Rb" runat="server" GroupName="A05" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A05_False_Rb" runat="server" GroupName="A05" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label12" runat="server" Text="控制器是否破損" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A06_True_Rb" runat="server" GroupName="A06" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A06_False_Rb" runat="server" GroupName="A06" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label13" runat="server" Text="整流器面板是否破損" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A07_True_Rb" runat="server" GroupName="A07" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A07_False_Rb" runat="server" GroupName="A07" Text="異常" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td class="RadioButton1">
                                                                    <asp:Label ID="Label14" runat="server" Text="安培表、伏特表是否正常" CssClass="font2"></asp:Label>
                                                                </td>
                                                                <td class="RadioButton2">
                                                                    <asp:RadioButton ID="A08_True_Rb" runat="server" GroupName="A08" Text="正常" />
                                                                </td>
                                                                <td class="RadioButton3">
                                                                    <asp:RadioButton ID="A08_False_Rb" runat="server" GroupName="A08" Text="異常" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </asp:View>
                <asp:View ID="View3" runat="server">
                    <asp:Button ID="MapImgBtn" runat="server" Text="返回" OnClick="MapImgBtn_Click" />
                    <asp:Image ID="MapImg" runat="server" ImageUrl="pic/CJHS_map.jpg" Height="100%" Width="100%" />
                </asp:View>
            </asp:MultiView>
            <div id="DivBack" runat="server" style="position: fixed; top: 0; left: 0; background: url(pic/BlackBG.png);
                width: 100%; height: 100%; z-index: 100;" visible="false">
            </div>
            <table id="PLI_CJHS_View" runat="server" width="100%" style="position: fixed; top: 20%;
                z-index: 200;" visible="false">
                <tr>
                    <td align="center">
                        <table style="background-color: #FFFFFF;">
                            <tr>
                                <td style="padding: 10px;">
                                    <table style="background-color: #FFFFFF; border-collapse: collapse;">
                                        <tr>
                                            <td align="left" style="padding-bottom: 10px; border-bottom: #0f6fc6 1px solid;">
                                                <asp:Label ID="Label4" runat="server" Text="檢視全區巡查點" CssClass="title1" ForeColor="#0f6fc6"
                                                    Font-Bold="true"></asp:Label>
                                            </td>
                                            <td align="right" style="padding-bottom: 10px; border-bottom: #0f6fc6 1px solid;">
                                                <asp:Button ID="CloseBtn" runat="server" OnClick="CloseBtn_Click" CssClass="ImageBtn"
                                                    Style="background-image: url(pic/close.png);" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" style="padding-top: 5px;">
                                                <asp:DataList ID="PLI_CJHS_Dl" runat="server" RepeatColumns="4" RepeatDirection="Horizontal">
                                                    <ItemTemplate>
                                                        <div style="padding: 5px;">
                                                            <asp:Button ID="ValueBtn" runat="server" Text='<%# Bind("Value") %>' OnClick="ValueBtn_Click"
                                                                CssClass="ValueBtn1" />
                                                            <asp:TextBox ID="SortTb" runat="server" Text='<%# Bind("Sort") %>' Visible="false"></asp:TextBox>
                                                            <asp:TextBox ID="NumberTb" runat="server" Text='<%# Bind("Number") %>' Visible="false"></asp:TextBox>
                                                        </div>
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <div id="visibleDiv" runat="server" visible="false">
                <asp:TextBox ID="HumanId" runat="server"></asp:TextBox>
                <asp:TextBox ID="OrgUnitId" runat="server"></asp:TextBox>
                <asp:TextBox ID="Inspection" runat="server"></asp:TextBox>
                <asp:TextBox ID="Send" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process1" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process2" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process3" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process4" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process5" runat="server"></asp:TextBox>
            </div>
            <input type="hidden" runat="server" id="latitude" />
            <input type="hidden" runat="server" id="longitude" />
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:Timer ID="Timer1" runat="server" Interval="60000" OnTick="Timer1_Tick">
    </asp:Timer>
    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel1"
        DynamicLayout="true">
        <ProgressTemplate>
            <div class="DivBack1" style="background: url(pic/BlackBG.png); background-repeat: repeat;">
                <div class="DivBack2">
                    <div class="DivBack3">
                        <img alt="" src="pic/please_wait.gif" style="z-index: 1000;" />
                        <br />
                        <asp:Label ID="LoagingLb" runat="server" Text="資料讀取中...請稍後..." CssClass="font-medium"
                            Style="z-index: 1000;"></asp:Label>
                    </div>
                </div>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>
    </form>
</body>
</html>
