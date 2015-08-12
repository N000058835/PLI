<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PLI.aspx.cs" Inherits="PLI.PLI" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>廠外管線巡檢系統</title>
    <link rel="apple-touch-icon" href="pic/formosa-144.png" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <link type="text/css" rel="stylesheet" media="screen and (max-width: 1024px)" href="css/1024-max-device.css" />
    <link type="text/css" rel="stylesheet" media="screen and (min-width: 1025px)" href="css/1025-min-device.css" />
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
                message: $('<h3 style="text-align:center"><img src="pic/please_wait.gif" /><br/>資料讀取中...請稍後...</h3>'),
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
            <asp:MultiView ID="MultiView1" runat="server">
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
                                    <asp:Label ID="Login1Lb" runat="server" Text="中油林園至台塑林園廠原物料管線" CssClass="login"></asp:Label>
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
                                            <td class="LoninBottom">
                                                <asp:TextBox ID="AccountTb" runat="server" CssClass="font-x-large" Width="250px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="Label2" runat="server" Text="密碼" CssClass="font-medium"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="LoninBottom">
                                                <asp:TextBox ID="PasswordTb" runat="server" TextMode="Password" CssClass="font-x-large"
                                                    Width="250px"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="left">
                                                <asp:Label ID="Label5" runat="server" Text="網域" CssClass="font-medium"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="LoninBottom">
                                                <asp:DropDownList ID="DomainDdl" runat="server" CssClass="font-x-large" Width="255px">
                                                    <asp:ListItem Value="tw.fpg.com">TWFPG</asp:ListItem>
                                                    <asp:ListItem Value="fpccmtn.tw.fpg.com">FPCCMTN</asp:ListItem>
                                                    <asp:ListItem Value="fpcetg.com">fpcetg</asp:ListItem>
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
                                <td>
                                    <asp:Button ID="SendBtn" runat="server" Text="呈核" OnClick="SendBtn_Click" CssClass="font-x-large"
                                        OnClientClick="this.disabled=true;" UseSubmitBehavior="False" />
                                </td>
                                <td align="center">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Image ID="logo" runat="server" ImageUrl="pic/logo-fpc.png" />
                                            </td>
                                            <td>
                                                <asp:Label ID="PipelineInspectionTitle" runat="server" Text="中油林園至台塑林園廠原物料管線巡檢紀錄表"
                                                    CssClass="title"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td align="right" valign="middle">
                                    <asp:Button ID="LoginOutBtn" runat="server" Text="登出" OnClick="LoginOutBtn_Click"
                                        CssClass="font-x-large" />
                                </td>
                            </tr>
                        </table>
                        <table width="100%" style="background-color: #7cca62;">
                            <tr>
                                <td align="center" valign="middle" style="padding: 0px 0px 0px 0px;">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Label ID="Label13" runat="server" Text="巡檢日期：" CssClass="font-x-large"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:DropDownList ID="DateDdl" runat="server" AutoPostBack="true" OnSelectedIndexChanged="DateDdl_SelectedIndexChanged"
                                                    CssClass="font-x-large">
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:Label ID="Label3" runat="server" Text="巡檢人員：" CssClass="font-x-large"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:Label ID="HumanName" runat="server" CssClass="font-x-large"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:Label ID="Label14" runat="server" Text="天候：" CssClass="font-x-large"></asp:Label>
                                            </td>
                                            <td style="padding-right: 70px;">
                                                <asp:DropDownList ID="WeatherDdl" runat="server" CssClass="font-x-large" Style="background-color: #ffffff;">
                                                    <asp:ListItem>晴天</asp:ListItem>
                                                    <asp:ListItem>陰天</asp:ListItem>
                                                    <asp:ListItem>雨天</asp:ListItem>
                                                    <asp:ListItem>颱風</asp:ListItem>
                                                </asp:DropDownList>
                                            </td>
                                            <td>
                                                <asp:Label ID="Label4" runat="server" Text="整流器位置：" CssClass="font-x-large"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:ImageButton ID="MapBtn" runat="server" ImageUrl="pic/map2.png" OnClick="MapBtn_Click"
                                                    ToolTip="佈置圖" Style="width: 40px; height: 40px;" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <table style="width: 100%; margin-top: 5px; border: none; border-collapse: collapse;">
                            <tr>
                                <td valign="top" style="width: 25%; padding-right: 15px;">
                                    <asp:DataList ID="RectifiersDl" runat="server" RepeatColumns="2" RepeatDirection="Vertical"
                                        Width="100%">
                                        <ItemTemplate>
                                            <asp:Button ID="RectifiersBtn" runat="server" Text='<%# Eval("Value") %>' OnClick="DlRectifiersBtn_Click"
                                                CssClass="Button" />
                                        </ItemTemplate>
                                        <ItemStyle Width="50%" />
                                    </asp:DataList>
                                </td>
                                <td valign="top" style="padding-right: 30px;">
                                    <asp:GridView ID="ItemGv" runat="server" AutoGenerateColumns="False" EnableModelValidation="True"
                                        ShowHeader="false" OnRowDataBound="ItemGv_RowDataBound" CssClass="GridView" OnRowCreated="ItemGv_RowCreated">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table width="100%" class="ItemGv">
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="Item" runat="server" CssClass="font-x-large" Text='<%# Eval("Item") %>'></asp:Label>
                                                            </td>
                                                            <td style="width: 90px; padding-right: 50px;">
                                                                <asp:RadioButton ID="TrueRBtn" runat="server" Text="正常" GroupName="AAA" CssClass="font-x-large" />
                                                            </td>
                                                            <td style="width: 90px;">
                                                                <asp:RadioButton ID="FalseRBtn" runat="server" Text="異常" GroupName="AAA" CssClass="font-x-large" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3">
                                                                <asp:TextBox ID="ValueTb" runat="server" onkeyup="this.value=this.value.replace(/[^0-9]/g,'')"
                                                                    CssClass="font-x-large" Style="width: 100%; border: none;"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                                <HeaderStyle CssClass="GridView" />
                                                <ItemStyle CssClass="GridView" />
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:TextBox ID="Input" runat="server" Text='<%# Bind("Input") %>'></asp:TextBox>
                                                    <asp:TextBox ID="Type" runat="server" Text='<%# Bind("Type") %>'></asp:TextBox>
                                                    <asp:TextBox ID="Sort" runat="server" Text='<%# Bind("Sort") %>'></asp:TextBox>
                                                    <asp:TextBox ID="Pid" runat="server" Text='<%# Bind("Pid") %>'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <HeaderStyle HorizontalAlign="Center" BackColor="#B2B2B2" Height="35px" />
                                        <RowStyle Height="35px" />
                                    </asp:GridView>
                                </td>
                                <td align="center" valign="top" class="PhotoTd">
                                    <table id="PhotoTable" runat="server" visible="false">
                                        <tr>
                                            <td colspan="2" align="center" valign="middle" class="PhotoTable">
                                                <div class="PhotoDiv">
                                                    <asp:DataList ID="PhotoDl" runat="server" RepeatDirection="Horizontal">
                                                        <ItemTemplate>
                                                            <table style="position: relative; top: 0px; z-index: 100;">
                                                                <tr>
                                                                    <td>
                                                                        <asp:Image ID="PhotoImg" runat="server" CssClass="Image" />
                                                                        <asp:Button ID="DeleteBtn" runat="server" OnClick="DeleteBtn_Click" OnClientClick="return confirm('您確定要刪除嗎?')"
                                                                            CssClass="DeleteBtn" Style="position: absolute; top: 1px; right: 1px; background-image: url(pic/delete.png);
                                                                            z-index: 100;" />
                                                                        <asp:TextBox ID="PhotoPidTb" runat="server" Visible="false"></asp:TextBox>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </ItemTemplate>
                                                    </asp:DataList>
                                                    <asp:Image ID="Photo2Img" runat="server" ImageUrl="pic/icon-camera.png" CssClass="Image"
                                                        Visible="false" />
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 5px 0px 5px 0px;">
                                                <asp:FileUpload ID="PhotoFu" runat="server" CssClass="font-x-large" />
                                            </td>
                                            <td style="padding: 5px 0px 5px 0px;">
                                                <asp:Button ID="PhotoBtn" runat="server" Text="上傳" OnClick="PhotoBtn_Click" OnClientClick="loading();"
                                                    CssClass="UploadButton" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="left" style="padding-bottom: 3px;">
                                                <asp:Label ID="Label6" runat="server" Text="異常或其他巡檢事項：" CssClass="font-x-large"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="center" style="padding-bottom: 3px;">
                                                <asp:TextBox ID="ValueTb" runat="server" Rows="5" TextMode="MultiLine" CssClass="font-x-large"
                                                    Style="width: 98%; overflow: auto;"></asp:TextBox>
                                                <asp:TextBox ID="ValuePidTb" runat="server" Visible="false"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="center">
                                                <asp:Button ID="SaveBtn" runat="server" Text="儲存" OnClick="SaveBtn_Click" CssClass="SaveButton" />
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
                    <asp:Image ID="MapImg" runat="server" ImageUrl="pic/map.jpg" Height="100%" Width="100%" />
                </asp:View>
            </asp:MultiView>
            <div id="visibleDiv" runat="server" visible="false">
                <asp:TextBox ID="Process" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process1" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process2" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process3" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process4" runat="server"></asp:TextBox>
                <asp:TextBox ID="Process5" runat="server"></asp:TextBox>
                <asp:TextBox ID="RectifiersClick" runat="server"></asp:TextBox>
                <asp:TextBox ID="IdNo" runat="server"></asp:TextBox>
                <asp:TextBox ID="ExtRealOrgId1" runat="server"></asp:TextBox>
                <asp:TextBox ID="Send" runat="server"></asp:TextBox>
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
