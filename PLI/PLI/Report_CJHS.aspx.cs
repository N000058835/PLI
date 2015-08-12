using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Microsoft.Reporting.WebForms;
using System.Data.SqlClient;
using System.Data;
using System.Web.Configuration;

namespace PLI
{
    public partial class Report_CJHS : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ReportViewer1.LocalReport.DataSources.Clear();

                ValueSet(ObjectDataSource1, "Underground");
                ValueSet(ObjectDataSource2, "Rectifiers");
                ValueSet(ObjectDataSource3, "Others");
                ValueSet(ObjectDataSource4, "Photo");

                ReportViewer1.LocalReport.Refresh();
            }
        }

        protected void ValueSet(ObjectDataSource ds, string Type)
        {
            ds.SelectParameters.Clear();
            ds.SelectMethod = "GetData";
            ds.SelectParameters.Add(new Parameter("Date", DbType.String, "2015/03/11"));
            ds.SelectParameters.Add(new Parameter("OrgUnitId", DbType.String, "1B"));
            ds.SelectParameters.Add(new Parameter("HumanId", DbType.String, "N000141636"));

            //將查詢出的 orders 資料表資料提供給 DataSet2_Orders
            ReportDataSource rds = new ReportDataSource(Type, ds.ID);            

            //將 資料 新增到 ReportViewer1 的 DataSources
            ReportViewer1.LocalReport.DataSources.Add(rds);            
        }
    }
}