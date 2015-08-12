<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Report_CJHS.aspx.cs" Inherits="PLI.Report_CJHS" %>

<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"
    Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <rsweb:ReportViewer ID="ReportViewer1" runat="server" Font-Names="Verdana" Font-Size="8pt"
            Height="768px" InteractiveDeviceInfos="(集合)" WaitMessageFont-Names="Verdana"
            WaitMessageFont-Size="14pt" Width="1024px">
            <LocalReport ReportPath="Report_CJHS.rdlc">
                <DataSources>
                    <rsweb:ReportDataSource DataSourceId="ObjectDataSource1" Name="Underground" />
                    <rsweb:ReportDataSource DataSourceId="ObjectDataSource2" Name="Rectifiers" />
                    <rsweb:ReportDataSource DataSourceId="ObjectDataSource3" Name="Others" />
                    <rsweb:ReportDataSource DataSourceId="ObjectDataSource4" Name="Photo" />
                </DataSources>
            </LocalReport>
        </rsweb:ReportViewer>
        <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" SelectMethod="GetData"
            TypeName="PLI.CJHSTableAdapters.PLI_CJHS_UndergroundTableAdapter" 
            OldValuesParameterFormatString="original_{0}">
            <SelectParameters>
                <asp:Parameter Name="Date" Type="String" />
                <asp:Parameter Name="OrgUnitId" Type="String" />
                <asp:Parameter Name="HumanId" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="ObjectDataSource2" runat="server" SelectMethod="GetData"
            TypeName="PLI.CJHSTableAdapters.PLI_CJHS_RectifiersTableAdapter" 
            OldValuesParameterFormatString="original_{0}">
            <SelectParameters>
                <asp:Parameter Name="Date" Type="String" />
                <asp:Parameter Name="OrgUnitId" Type="String" />
                <asp:Parameter Name="HumanId" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="ObjectDataSource3" runat="server" SelectMethod="GetData"
            TypeName="PLI.CJHSTableAdapters.PLI_CJHS_OthersTableAdapter" 
            OldValuesParameterFormatString="original_{0}">
            <SelectParameters>
                <asp:Parameter Name="Date" Type="String" />
                <asp:Parameter Name="OrgUnitId" Type="String" />
                <asp:Parameter Name="HumanId" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
        <asp:ObjectDataSource ID="ObjectDataSource4" runat="server" SelectMethod="GetData"
            TypeName="PLI.CJHSTableAdapters.PLI_CJHS_PhotoTableAdapter" 
            OldValuesParameterFormatString="original_{0}">
            <SelectParameters>
                <asp:Parameter Name="Date" Type="String" />
                <asp:Parameter Name="OrgUnitId" Type="String" />
                <asp:Parameter Name="HumanId" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </div>
    </form>
</body>
</html>
