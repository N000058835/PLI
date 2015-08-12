<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GPS.aspx.cs" Inherits="PLI.GPS" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
    <script type="text/javascript" src="map/jquery.min.js"></script>
    <script type="text/javascript" src="map/jquery.tinyMap.min.js"></script>
    <script type="text/javascript">
        function GetGPS() {
            //alert("test");
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

        $(document).ready(function () {
            Map();
        });

        function Map() {
            $('#map').tinyMap({
                center: ['25.0392', '121.525002'],
                zoom: 13,
                marker: [
                            { addr: ['25.0392', '121.525002'] }
                        ]
            });
        }

        //        function Map() {
        //            $('#map').tinyMap({
        //                center: '台北市安東街35巷',
        //                zoom: 13,
        //                polyline: [{
        //                    coords: [
        //            [25.05176362315452, 121.54683386230465],
        //            [25.0587614830369, 121.55301367187496],
        //            [25.05673992011185, 121.56005178833004],
        //        ],
        //                    color: '#000000',
        //                    width: 2
        //                }]
        //            });
        //        }

        function tinyMap(StrLatitude, StrLongitude) {
            var Latitude = StrLatitude.split(",");
            var Longitude = StrLongitude.split(",");
            var colModel1 = [];
            var drawline = [];

            for (var i = 0; i < Latitude.length; i++) {
                colModel1.push({ addr: [Latitude[i], Longitude[i]] });
                drawline.push([Latitude[i], Longitude[i]]);
            }

            $('#map').tinyMap({
                center: ['22.610932387037', '120.29992172963'],
                zoom: 14,
                marker: colModel1,
                polyline: [{
                    coords: drawline,
                    color: '#000000',
                    width: 2
                }]
            });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <%--<asp:Button ID="MailBtn" runat="server" Text="寄信" OnClick="MailBtn_Click" />--%>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Button ID="MapBtn" runat="server" Text="地圖" OnClick="MapBtn_Click" />
            <asp:ScriptManager ID="ScriptManager1" runat="server">
            </asp:ScriptManager>
            <%--<asp:Timer ID="Timer1" runat="server" Interval="60000" OnTick="Timer1_Tick">
            </asp:Timer>--%>
            <input type="hidden" runat="server" id="latitude" />
            <input type="hidden" runat="server" id="longitude" />
            <div id="map" runat="server" style="width: 1024px; height: 768px; display: none;">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
