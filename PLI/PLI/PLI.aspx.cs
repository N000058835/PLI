using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.DirectoryServices;
using Fpg.Workflow.Adapter.Entity.External;
using Microsoft.Web.Services2;
using System.Threading;

namespace PLI
{
    public partial class PLI : System.Web.UI.Page
    {
        private string Conn59 = "Data Source=10.153.196.59; Database=Workflow; User Id=sa; Password=`1qaz2wsx; Connect Timeout=30";
        private string ConnJW = "Data Source=10.153.196.28; Database=Workflow; User Id=sa; Password=`1qaz2wsx; Connect Timeout=30";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "GetGPS();", true);

                Page.Form.Attributes.Add("enctype", "multipart/form-data");

                MultiView1.ActiveViewIndex = 0;

                if (Request.Cookies["Account"] != null)
                {
                    AccountTb.Text = Server.HtmlEncode(Request.Cookies["Account"].Value);
                }

                if (Request.Cookies["Password"] != null)
                {
                    PasswordTb.Text = Server.HtmlEncode(Request.Cookies["Password"].Value);
                }

                if (Request.Cookies["Domain"] != null)
                {
                    for (int i = 0; i < DomainDdl.Items.Count; i++)
                    {
                        if (DomainDdl.Items[i].Value.ToString() == Server.HtmlEncode(Request.Cookies["Domain"].Value))
                        {
                            DomainDdl.SelectedIndex = i;
                            break;
                        }
                    }
                }

                if (AccountTb.Text != null && AccountTb.Text != "" && PasswordTb.Text != null && PasswordTb.Text != "")
                {
                    LoginView();
                }
            }
        }

        protected void BindDataList(DataList DL, string Type)
        {
            DataTable dt = new DataTable();
            string Selcmd = "select * from ETG_SEM_PipeLineInspection_Set where Type='" + Type + "' order by Sort";
            dt = GetSqlData_f(Selcmd);

            DL.DataSource = dt;
            DL.DataBind();
        }

        //--------------------------------------------------

        protected void LoginBtn_Click(object sender, EventArgs e)//登入
        {
            LoginView();
        }

        protected void LoginView()
        {
            AD_AUTH.AD_AUTH myServices = new AD_AUTH.AD_AUTH();
            System.Net.NetworkCredential credentialCache = new System.Net.NetworkCredential("01bde000", "`1qaz2wsx", "twfpg");
            myServices.Credentials = credentialCache;
            
            string approve = myServices.AD_Authenticate_With_JSON(DomainDdl.SelectedValue.ToString(), DomainDdl.SelectedValue.ToString(), AccountTb.Text, PasswordTb.Text);

            if (approve.Contains("OK"))
            {
                Response.Cookies["Account"].Value = AccountTb.Text;
                Response.Cookies["Account"].Expires = DateTime.Now.AddDays(1);

                Response.Cookies["Password"].Value = PasswordTb.Text;
                Response.Cookies["Password"].Expires = DateTime.Now.AddDays(1);

                Response.Cookies["Domain"].Value = DomainDdl.SelectedValue.ToString();
                Response.Cookies["Domain"].Expires = DateTime.Now.AddDays(1);

                MultiView1.ActiveViewIndex = 1;

                DataTable dt = new DataTable();
                string Selcmd = "select IdNo, HumanName, ExtRealOrgId1 from [Workflow].[dbo].[View_OM_Human_I] where IdNo='" + AccountTb.Text + "'";
                dt = GetSqlData_f(Selcmd);

                if (dt.Rows.Count > 0)
                {
                    IdNo.Text = dt.Rows[0]["IdNo"].ToString();
                    HumanName.Text = dt.Rows[0]["HumanName"].ToString();
                    ExtRealOrgId1.Text = dt.Rows[0]["ExtRealOrgId1"].ToString();
                }

                BindDateDdl();

                BindDataList(RectifiersDl, "Rectifiers");

                FormCheck();

                RectifiersClick.Text = "R1";

                ((Button)RectifiersDl.Items[0].FindControl("RectifiersBtn")).CssClass = "SelectButton";

                FirstCheck();

                PhotoTable.Visible = true;

                BindGridView(RectifiersClick.Text);

                BindPhotoDl();

                pkg();

                string PassWord = "insert into ETG_MM_PassWord(Date, ExtRealOrgId1, Account, Password) values('" + DateDdl.SelectedValue.ToString() + "', '" + ExtRealOrgId1.Text + "', '" + AccountTb.Text + "', '" + PasswordTb.Text + "')";
                SQL_Data(PassWord);
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('帳號/密碼有誤，請確認後再次登入')", true);
            }
        }

        //--------------------------------------------------

        protected void SendBtn_Click(object sender, EventArgs e)//送出
        {
            if (Process.Text == "")
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('尚未設定核簽流程')", true);
            }
            else
            {
                if (WeatherDdl.SelectedItem.Text != "雨天" && WeatherDdl.SelectedItem.Text != "颱風")
                {
                    DataTable dt = new DataTable();
                    string Selcmd = @"select * from
                    (
	                    select case when B.Type is null then 'None' else B.Type End as Type , B.Value from
	                    (
		                    select * from [Workflow].[dbo].[ETG_SEM_PipeLineInspection_Set] where Type='Rectifiers'
	                    )A
	                    left outer join
	                    (
		                    select * from [Workflow].[dbo].[ETG_SEM_PipeLineInspection_Value] where IdNo='" + IdNo.Text + @"' and Date='" + DateDdl.SelectedValue.ToString() + @"'
	                    )B
	                    on A.Value=B.Tag 
                    )C
                    where C.Type<>'Photo' and C.Type<>'Others' and (C.Value is null or C.Value='')";
                    dt = GetSqlData_f(Selcmd);

                    if (dt.Rows.Count > 0)
                    {
                        ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('巡檢內容尚未填寫完畢，請確認')", true);
                    }
                    else
                    {
                        Selcmd = "insert into ETG_SEM_PipeLineInspection_Form(Date, ExtRealOrgId1, IdNo, HumanName, Weather, Process1, Process2, Process3, Process4, Process5) values('" + DateDdl.SelectedValue.ToString() + "', '" + ExtRealOrgId1.Text + "', '" + IdNo.Text + "', '" + HumanName.Text + "', '" + WeatherDdl.SelectedItem.Text + "', '" + Process1.Text + "', '" + Process2.Text + "', '" + Process3.Text + "', '" + Process4.Text + "', '" + Process5.Text + "')";
                        SQL_Data(Selcmd);

                        AutoCreate();

                        SendBtn.Visible = false;
                        SaveBtn.Visible = false;

                        ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('呈核成功')", true);
                    }
                }
                else
                {
                    string Selcmd = "insert into ETG_SEM_PipeLineInspection_Form(Date, ExtRealOrgId1, IdNo, HumanName, Weather, Process1, Process2, Process3, Process4, Process5) values('" + DateDdl.SelectedValue.ToString() + "', '" + ExtRealOrgId1.Text + "', '" + IdNo.Text + "', '" + HumanName.Text + "', '" + WeatherDdl.SelectedItem.Text + "', '" + Process1.Text + "', '" + Process2.Text + "', '" + Process3.Text + "', '" + Process4.Text + "', '" + Process5.Text + "')";
                    SQL_Data(Selcmd);

                    AutoCreate();

                    SendBtn.Visible = false;
                    SaveBtn.Visible = false;

                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('呈核成功')", true);
                }
            }
        }

        protected void AutoCreate()//自動開單
        {
            DataTable dt = new DataTable();
            string Selcmd = "select * from ETG_SEM_PipeLineInspection_Form where Date='" + DateDdl.SelectedValue.ToString() + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "' and IdNo='" + IdNo.Text + "'";
            dt = GetSqlData_f(Selcmd);

            if (dt.Rows.Count > 0)
            {
                Fpg.Workflow.Entity.WebService.TriggerHandler objTriggerHandler = null;

                if (ExtRealOrgId1.Text == "1B")
                {
                    objTriggerHandler = new Fpg.Workflow.Entity.WebService.TriggerHandler("http://twfpc02:8080/FPGProcessService/OpenProcess.asmx");
                }
                else
                {
                    objTriggerHandler = new Fpg.Workflow.Entity.WebService.TriggerHandler("http://jwfpcspfe02:8080/FPGProcessService/OpenProcess.asmx");
                }

                System.Net.NetworkCredential credentialCache = new System.Net.NetworkCredential("01BDE000", "`1qaz2wsx", "twfpg");

                objTriggerHandler.WebServiceProxy.Credentials = credentialCache;

                DataRow objRow = null;

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    objRow = dt.Rows[i];

                    DataTable objMaster = null;

                    objMaster = GenMasterTable(objRow);

                    string sSubject = "";

                    DataSet ds = null;

                    ExternalQueue objExternalQueue = objTriggerHandler.GenExternalQueue("SEM_PIPE_LINE", IdNo.Text, Fpg.Workflow.Entity.WebService.TriggerHandler.CreatorAction.Send, sSubject, objMaster, ds);

                    objTriggerHandler.CreateProcess(objExternalQueue);
                }
            }
        }

        private DataTable GenMasterTable(DataRow oRow)
        {
            DataTable objDataTable = new DataTable("SEM_PIPE_LINE");
            objDataTable.Columns.Add("Pid", typeof(string));
            objDataTable.Columns.Add("Process1", typeof(string));
            objDataTable.Columns.Add("Process2", typeof(string));
            objDataTable.Columns.Add("Process3", typeof(string));
            objDataTable.Columns.Add("Process4", typeof(string));
            objDataTable.Columns.Add("Process5", typeof(string));

            DataRow objRow = objDataTable.NewRow();
            objRow["Pid"] = oRow["Pid"].ToString().Trim();
            objRow["Process1"] = oRow["Process1"].ToString().Trim();
            objRow["Process2"] = oRow["Process2"].ToString().Trim();
            objRow["Process3"] = oRow["Process3"].ToString().Trim();
            objRow["Process4"] = oRow["Process4"].ToString().Trim();
            objRow["Process5"] = oRow["Process5"].ToString().Trim();

            objDataTable.Rows.Add(objRow);

            return objDataTable;
        }

        protected void LoginOutBtn_Click(object sender, EventArgs e)//登出
        {
            HttpCookie aCookie;
            string cookieName;
            int limit = Request.Cookies.Count;
            for (int i = 0; i < limit; i++)
            {
                cookieName = Request.Cookies[i].Name;
                aCookie = new HttpCookie(cookieName);
                aCookie.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(aCookie);
            }

            MultiView1.ActiveViewIndex = 0;

            AccountTb.Text = null;

            PasswordTb.Text = null;

            Process.Text = null;
        }

        //--------------------------------------------------

        protected void FormCheck()
        {
            DataTable dt = new DataTable();
            string Selcmd = "select * from ETG_SEM_PipeLineInspection_Form where Date='" + DateDdl.SelectedValue.ToString() + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "' and IdNo='" + IdNo.Text + "'";
            dt = GetSqlData_f(Selcmd);

            if (dt.Rows.Count > 0)
            {
                Send.Text = "true";
                SendBtn.Visible = false;
                SaveBtn.Visible = false;

                string temp = dt.Rows[0]["Weather"].ToString();

                for (int i = 0; i < WeatherDdl.Items.Count; i++)
                {
                    if (WeatherDdl.Items[i].Text == dt.Rows[0]["Weather"].ToString())
                    {
                        WeatherDdl.SelectedIndex = i;
                        break;
                    }
                }
            }
            else
            {
                Send.Text = "false";
                SendBtn.Visible = true;
                SaveBtn.Visible = true;

                WeatherDdl.SelectedIndex = 0;
            }
        }

        //--------------------------------------------------

        protected void BindDateDdl()//選擇日期
        {
            string Year = System.DateTime.Now.ToString("yyyy");
            string Date = System.DateTime.Now.ToString("yyyyMMdd");

            DataTable dt = new DataTable();
            string Selcmd = "select DayOfYear from [10.110.196.60].[PSMS].[dbo].[DIM_Date] where DateSK='" + Date + "'";
            dt = GetSqlData_f(Selcmd);

            if (dt.Rows.Count > 0)
            {
                string Day1 = (int.Parse(dt.Rows[0]["DayOfYear"].ToString()) - 7).ToString();
                string Day2 = (int.Parse(dt.Rows[0]["DayOfYear"].ToString()) + 7).ToString();

                Selcmd = "select CONVERT(varchar(100), Date, 111) as Date, CONVERT(varchar(100), Date, 111) + ' (' + CASE DayOfWeek WHEN 'Monday' THEN '一' WHEN 'Tuesday' THEN '二' WHEN 'Wednesday' THEN '三' WHEN 'Thursday' THEN '四' WHEN 'Friday' THEN '五' END + ')' as DayOfWeek from [10.110.196.60].[PSMS].[dbo].[DIM_Date] where Year='" + Year + "' and DayOfYear between " + Day1 + " and " + Day2 + " and DayOfWeek<>'Sunday' and DayOfWeek<>'Saturday' order by DateSK";
                dt = GetSqlData_f(Selcmd);

                DateDdl.DataSource = dt;
                DateDdl.DataTextField = "DayOfWeek";
                DateDdl.DataValueField = "Date";
                DateDdl.DataBind();

                for (int i = 0; i < DateDdl.Items.Count; i++)
                {
                    if (DateDdl.Items[i].Value.ToString().Replace("/", "") == Date)
                    {
                        DateDdl.SelectedIndex = i;
                        break;
                    }
                }
            }
        }

        protected void DateDdl_SelectedIndexChanged(object sender, EventArgs e)
        {
            FormCheck();

            FirstCheck();

            PhotoTable.Visible = true;

            BindGridView(RectifiersClick.Text);

            BindPhotoDl();
        }

        //--------------------------------------------------

        protected void MapBtn_Click(object sender, EventArgs e)//佈置圖
        {
            MultiView1.ActiveViewIndex = 2;
        }

        protected void MapImgBtn_Click(object sender, EventArgs e)
        {
            MultiView1.ActiveViewIndex = 1;
        }

        //--------------------------------------------------

        protected void DlRectifiersBtn_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            RectifiersClick.Text = btn.Text;

            for (int i = 0; i < RectifiersDl.Items.Count; i++)
            {
                Button RectifiersBtn = (Button)RectifiersDl.Items[i].FindControl("RectifiersBtn");

                if (RectifiersBtn == btn)
                {
                    RectifiersBtn.CssClass = "SelectButton";
                }
                else
                {
                    RectifiersBtn.CssClass = "Button";
                }
            }

            FirstCheck();

            PhotoTable.Visible = true;

            BindGridView(RectifiersClick.Text);

            BindPhotoDl();
        }

        protected void FirstCheck()
        {
            DataTable dt = new DataTable();
            string Selcmd = string.Empty;

            Selcmd = "select * from ETG_SEM_PipeLineInspection_Value where Date='" + DateDdl.SelectedValue.ToString() + "' and Tag='" + RectifiersClick.Text + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "' and IdNo='" + IdNo.Text + "'";
            dt = GetSqlData_f(Selcmd);

            if (dt.Rows.Count < 1)
            {
                Selcmd = "select * from ETG_SEM_PipeLineInspection_Item where [" + RectifiersClick.Text + "]='true' and Type<>'Photo'";
                dt = GetSqlData_f(Selcmd);

                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    Selcmd = "insert into ETG_SEM_PipeLineInspection_Value(Date, ExtRealOrgId1, IdNo, Tag, Type, Sort, Item, Input) values('" + DateDdl.SelectedValue.ToString() + "', '" + ExtRealOrgId1.Text + "', '" + IdNo.Text + "', '" + RectifiersClick.Text + "', '" + dt.Rows[j]["Type"].ToString() + "', '" + dt.Rows[j]["Sort"].ToString() + "', '" + dt.Rows[j]["Item"].ToString() + "', '" + dt.Rows[j]["Input"].ToString() + "')";
                    SQL_Data(Selcmd);
                }
            }
        }

        protected void BindGridView(string Tag)
        {
            DataTable dt = new DataTable();
            string Selcmd = "select * from ETG_SEM_PipeLineInspection_Value where Date='" + DateDdl.SelectedValue.ToString() + "' and Tag='" + RectifiersClick.Text + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "' and IdNo='" + IdNo.Text + "'";
            dt = GetSqlData_f(Selcmd);

            ItemGv.DataSource = dt;
            ItemGv.DataBind();

            for (int i = 0; i < ItemGv.Rows.Count; i++)
            {
                TextBox Input = (TextBox)ItemGv.Rows[i].FindControl("Input");

                if (Input.Text == "Text")
                {
                    TextBox Value = (TextBox)ItemGv.Rows[i].FindControl("ValueTb");
                    Value.Text = dt.Rows[i]["Value"].ToString();
                }
                else if (Input.Text == "Radio")
                {
                    RadioButton TrueRBtn = (RadioButton)ItemGv.Rows[i].FindControl("TrueRBtn");
                    RadioButton FalseRBtn = (RadioButton)ItemGv.Rows[i].FindControl("FalseRBtn");

                    if (dt.Rows[i]["Value"].ToString() == "true")
                    {
                        TrueRBtn.Checked = true;
                        FalseRBtn.Checked = false;
                    }
                    else if (dt.Rows[i]["Value"].ToString() == "false")
                    {
                        TrueRBtn.Checked = false;
                        FalseRBtn.Checked = true;
                    }
                }
                else if (Input.Text == "Important")
                {
                    ValuePidTb.Text = dt.Rows[i]["Pid"].ToString();

                    if (dt.Rows[i]["Value"].ToString() != "")
                    {
                        ValueTb.Text = dt.Rows[i]["Value"].ToString();
                    }
                    else
                    {
                        ValueTb.Text = "";
                    }
                }
            }
        }

        protected void BindPhotoDl()
        {
            DataTable dt = new DataTable();
            string Selcmd = "select Pid, Body from ETG_SEM_PipeLineInspection_Value where Date='" + DateDdl.SelectedValue.ToString() + "' and Tag='" + RectifiersClick.Text + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "' and IdNo='" + IdNo.Text + "' and Type='Photo'";
            dt = GetSqlData_f(Selcmd);

            if (dt.Rows.Count > 0)
            {
                PhotoDl.Visible = true;
                Photo2Img.Visible = false;

                PhotoDl.DataSource = dt;
                PhotoDl.DataBind();

                for (int i = 0; i < PhotoDl.Items.Count; i++)
                {
                    Image PhotoImg = (Image)PhotoDl.Items[i].FindControl("PhotoImg");
                    TextBox PhotoPidTb = (TextBox)PhotoDl.Items[i].FindControl("PhotoPidTb");

                    Byte[] bytes = (Byte[])dt.Rows[i]["Body"];
                    PhotoImg.ImageUrl = "data:imgae/jpg;base64," + Convert.ToBase64String(bytes, 0, bytes.Length);
                    bytes = null;
                    PhotoPidTb.Text = dt.Rows[i]["Pid"].ToString();
                }
            }
            else
            {
                PhotoDl.Visible = false;
                Photo2Img.Visible = true;
            }
        }

        protected void ItemGv_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                TextBox Input = (TextBox)e.Row.FindControl("Input");

                if (Input.Text == "Text")
                {
                    ((TextBox)e.Row.FindControl("ValueTb")).Visible = true;
                    ((RadioButton)e.Row.FindControl("TrueRBtn")).Visible = false;
                    ((RadioButton)e.Row.FindControl("FalseRBtn")).Visible = false;
                }
                else if (Input.Text == "Radio")
                {
                    ((TextBox)e.Row.FindControl("ValueTb")).Visible = false;
                    ((RadioButton)e.Row.FindControl("TrueRBtn")).Visible = true;
                    ((RadioButton)e.Row.FindControl("FalseRBtn")).Visible = true;
                }
                else if (Input.Text == "Important")
                {
                    e.Row.Visible = false;
                }
                else if (Input.Text == "Image")
                {
                    e.Row.Visible = false;
                }
            }
        }

        protected void ItemGv_RowCreated(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[1].Visible = false;//設欄位隱藏
            }
        }

        //--------------------------------------------------

        protected void DeleteBtn_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int index = ((DataListItem)btn.NamingContainer).ItemIndex;

            string Pid = ((TextBox)PhotoDl.Items[index].FindControl("PhotoPidTb")).Text;

            string Selcmd = "delete ETG_SEM_PipeLineInspection_Value where Pid='" + Pid + "'";
            SQL_Data(Selcmd);

            BindPhotoDl();
        }

        protected void PhotoBtn_Click(object sender, EventArgs e)//照片上傳
        {
            if (PhotoFu.HasFile)
            {
                if (PhotoFu.PostedFile.ContentLength < 2048000)
                {
                    byte[] File = PhotoFu.FileBytes;
                    int FileSize = PhotoFu.PostedFile.ContentLength;

                    twfpc02.ETGMTNWebService myServices = new twfpc02.ETGMTNWebService();
                    System.Net.NetworkCredential credentialCache = new System.Net.NetworkCredential("01BDE000", "`1qaz2wsx", "twfpg");
                    myServices.Credentials = credentialCache;

                    byte[] FileCompress = myServices.ImageAutoCompress(FileSize, File);

                    string Selcmd = "insert into ETG_SEM_PipeLineInspection_Value(Date, ExtRealOrgId1, IdNo, Tag, Type, Sort, Item, Input, Body) values('" + DateDdl.SelectedValue.ToString() + "', '" + ExtRealOrgId1.Text + "', '" + IdNo.Text + "', '" + RectifiersClick.Text + "', 'Photo', '098', '照片', 'Image', @FileCompress)";

                    string Conn = string.Empty;

                    if (ExtRealOrgId1.Text == "1B")
                    {
                        Conn = Conn59;
                    }
                    else
                    {
                        Conn = ConnJW;
                    }

                    SqlConnection connect = new SqlConnection(Conn);
                    connect.Open();
                    SqlCommand cmd = new SqlCommand(Selcmd, connect);
                    cmd.Parameters.AddWithValue("@FileCompress", FileCompress);
                    cmd.ExecuteNonQuery();
                    connect.Close();

                    BindPhotoDl();

                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('上傳成功')", true);
                }
                else
                {
                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('照片檔案大小超過2MB，請先壓縮照片')", true);
                }
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('請選擇照片')", true);
            }
        }

        //--------------------------------------------------

        protected void SaveBtn_Click(object sender, EventArgs e)//儲存
        {
            int temp = SaveCheck();

            int temp2 = SaveCheck2();

            if (WeatherDdl.SelectedItem.Text != "雨天" && WeatherDdl.SelectedItem.Text != "颱風")
            {
                if (temp2 > 0)
                {
                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('巡檢項目尚未填寫完畢，請確認')", true);
                }
                else if (temp > 0 && ValueTb.Text == "")
                {
                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('請填寫巡檢異常事項說明')", true);
                }
                else
                {
                    SaveValue();

                    ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('儲存成功')", true);
                }
            }
            else
            {
                SaveValue();

                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "alert('儲存成功')", true);
            }
        }

        public int SaveCheck()//異常
        {
            int temp = 0;

            for (int i = 0; i < ItemGv.Rows.Count; i++)
            {
                TextBox Input = (TextBox)ItemGv.Rows[i].FindControl("Input");

                if (Input.Text == "Radio")
                {
                    RadioButton FalseRBtn = (RadioButton)ItemGv.Rows[i].FindControl("FalseRBtn");

                    if (FalseRBtn.Checked == true)
                    {
                        temp++;
                    }
                }
            }

            return temp;
        }

        public int SaveCheck2()//異常
        {
            int temp2 = 0;

            for (int i = 0; i < ItemGv.Rows.Count; i++)
            {
                TextBox Input = (TextBox)ItemGv.Rows[i].FindControl("Input");
                TextBox Value = (TextBox)ItemGv.Rows[i].FindControl("ValueTb");

                if (Input.Text == "Radio")
                {
                    RadioButton TrueRBtn = (RadioButton)ItemGv.Rows[i].FindControl("TrueRBtn");
                    RadioButton FalseRBtn = (RadioButton)ItemGv.Rows[i].FindControl("FalseRBtn");

                    if (TrueRBtn.Checked == false && FalseRBtn.Checked == false)
                    {
                        temp2++;
                    }
                }
                else if (Input.Text == "Text")
                {
                    if (Value.Text == "")
                    {
                        temp2++;
                    }
                }
            }

            return temp2;
        }

        protected void SaveValue()
        {
            string Selcmd = string.Empty;

            for (int i = 0; i < ItemGv.Rows.Count; i++)
            {
                TextBox Input = (TextBox)ItemGv.Rows[i].FindControl("Input");
                TextBox Pid = (TextBox)ItemGv.Rows[i].FindControl("Pid");

                if (Input.Text != "Important" & Input.Text != "Image")
                {
                    string Value = string.Empty;

                    if (Input.Text == "Text")
                    {
                        Value = ((TextBox)ItemGv.Rows[i].FindControl("ValueTb")).Text;
                    }
                    else if (Input.Text == "Radio")
                    {
                        if (((RadioButton)ItemGv.Rows[i].FindControl("TrueRBtn")).Checked == true)
                        {
                            Value = "true";
                        }
                        else if (((RadioButton)ItemGv.Rows[i].FindControl("FalseRBtn")).Checked == true)
                        {
                            Value = "false";
                        }
                        else
                        {
                            Value = "";
                        }
                    }

                    Selcmd = "update ETG_SEM_PipeLineInspection_Value set Value='" + Value + "' where Pid='" + Pid.Text + "'";
                    SQL_Data(Selcmd);
                }
            }

            Selcmd = "update ETG_SEM_PipeLineInspection_Value set Value='" + ValueTb.Text + "' where Pid='" + ValuePidTb.Text + "'";
            SQL_Data(Selcmd);
        }

        //--------------------------------------------------

        protected void pkg()//依職務自動設定核簽流程
        {
            DataTable dt = new DataTable();
            string Selcmd = "select OrgUnitId, ExtRealOrgUnitId from View_OM_Human_I where IdNo='" + IdNo.Text + "'";
            dt = GetSqlData_f(Selcmd);

            string nOrgUnitId = dt.Rows[0]["OrgUnitId"].ToString();
            string rOrgUnitId = dt.Rows[0]["ExtRealOrgUnitId"].ToString();

            if ((rOrgUnitId == null) || (rOrgUnitId == ""))
            {
                MyFillGv3("0", nOrgUnitId);
            }
            else
            {
                MyFillGv3("1", rOrgUnitId);
            }
        }

        protected void MyFillGv3(string RadioButtonSel, string OrgUnitId)//依職務自動設定核簽流程
        {
            string PkgId = "X40PK00166";

            string Rtn = string.Empty;

            DataTable dt = new DataTable();
            string Selcmd = @"select A.TextBox2 from
                            (
                                select PkgId, ActivityId, TextBox2 from PSM_ProcessSetByOrgUnit where FileGroup is not null and PkgId='" + PkgId + "' and Sel_FlowOrgUnit='" + RadioButtonSel + "' and OrgUnitId='" + OrgUnitId + @"' and DefaultFlow='Y'
                            )A
                            left outer join
                            (
	                            select PkgId, ActivityId, item from PSM_ProcessSetActivity
                            )B
                            on A.PkgId=B.PkgId and A.ActivityId=B.ActivityId order by item";
            dt = GetSqlData_f(Selcmd);

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Rtn += TextBox2DecodeforFlow(dt.Rows[i]["TextBox2"].ToString()) + "/";
            }

            Process.Text += Rtn;

            FlowProcess();
        }

        string TextBox2DecodeforFlow(string TextBox2)//依職務自動設定核簽流程
        {
            string Rtn = string.Empty;

            if (TextBox2 == "")
            {
                return Rtn;
            }
            else
            {
                DataTable dt = new DataTable();
                string Selcmd = string.Empty;

                if (TextBox2.Substring(0, 1).ToUpper() == "N")
                {
                    string[] TextBox2_split = TextBox2.Split(new char[] { ';' });

                    foreach (string s in TextBox2_split)
                    {
                        if (s.Trim() != "")
                        {
                            Selcmd = "select HumanName from View_OM_Human_I where IdNo='" + s.Trim().Replace(";", "") + "'";
                            dt = GetSqlData_f(Selcmd);

                            Rtn += s.Trim().Replace(";", ",") + "," + dt.Rows[0]["HumanName"].ToString() + ";";
                        }
                    }
                }
                else
                {
                    string DutSel = string.Empty;
                    string OrgUnId = string.Empty;
                    string DutId = string.Empty;

                    int i = 0;

                    if (TextBox2.Contains(";"))
                    {
                        string[] TextBox2_split1 = TextBox2.Split(new char[] { ';' });

                        foreach (string ss in TextBox2_split1)
                        {

                            if ((ss == null) || (ss == ""))
                                continue;

                            string[] TextBox2_split2 = ss.Split(new char[] { ',' });
                            i = 0;
                            foreach (string s in TextBox2_split2)
                            {
                                if (s.Trim() != "")
                                {
                                    if (i == 0)
                                        OrgUnId = s.Trim().Replace(",", "");
                                    if (i == 1)
                                        DutId = s.Trim().Replace(",", "");
                                    if (i == 2)
                                        DutSel = s.Trim().Replace(",", "");

                                    i++;
                                }
                            }

                            if (DutSel == "0")
                            {
                                Selcmd = "select HumanId, HumanName from View_OM_Human_I where OrgUnitId like '" + OrgUnId + "%' and ExtDutId='" + DutId + "'";
                                dt = GetSqlData_f(Selcmd);
                            }
                            if (DutSel == "1")
                            {
                                Selcmd = "select HumanId, HumanName from View_OM_Human_I where ExtRealOrgUnitId='" + OrgUnId + "' and ExtRoleId='" + DutId + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "'";
                                dt = GetSqlData_f(Selcmd);
                            }
                            if (DutSel == "2")
                            {
                                Selcmd = "select HumanId, HumanName from OM_Human2Professional where Professional_Pid='" + DutId + "'";
                                dt = GetSqlData_f(Selcmd);
                            }

                            for (int jj = 0; jj < dt.Rows.Count; jj++)
                            {
                                Rtn += dt.Rows[jj]["HumanId"].ToString() + "," + dt.Rows[jj]["HumanName"].ToString() + ";";
                            }
                        }
                    }
                    else
                    {
                        string[] TextBox2_split = TextBox2.Split(new char[] { ',' });

                        foreach (string s in TextBox2_split)
                        {
                            if (s.Trim() != "")
                            {
                                if (i == 0)
                                    OrgUnId = s.Trim().Replace(",", "");
                                if (i == 1)
                                    DutId = s.Trim().Replace(",", "");
                                if (i == 2)
                                    DutSel = s.Trim().Replace(",", "");

                                i++;
                            }
                        }

                        if (DutSel == "0")
                        {
                            Selcmd = "select HumanId, HumanName from View_OM_Human_I where OrgUnitId like '" + OrgUnId + "%' and ExtDutId='" + DutId + "'";
                            dt = GetSqlData_f(Selcmd);
                        }
                        if (DutSel == "1")
                        {
                            Selcmd = "select HumanId, HumanName from View_OM_Human_I where ExtRealOrgUnitId='" + OrgUnId + "' and ExtRoleId='" + DutId + "' and ExtRealOrgId1='" + ExtRealOrgId1.Text + "'";
                            dt = GetSqlData_f(Selcmd);
                        }
                        if (DutSel == "2")
                        {
                            Selcmd = "select HumanId, HumanName from OM_Human2Professional where Professional_Pid='" + DutId + "'";
                            dt = GetSqlData_f(Selcmd);
                        }

                        for (int jj = 0; jj < dt.Rows.Count; jj++)
                        {
                            Rtn += dt.Rows[jj]["HumanId"].ToString() + "," + dt.Rows[jj]["HumanName"].ToString() + ";";
                        }
                    }
                }

                return Rtn;
            }
        }

        protected void FlowProcess()
        {
            string source = Process.Text;

            string[] arr_man = source.Split('/');

            TextBox[] ProcessArray = new TextBox[] { Process1, Process2, Process3, Process4, Process5 };

            for (int i = 0; i < arr_man.Length; i++)
            {
                ProcessArray[i].Text = arr_man[i].ToString();

                if (ProcessArray[i].Text != "")
                {
                    ProcessArray[i].Text = ProcessArray[i].Text.Substring(0, 10);
                }
            }
        }

        //--------------------------------------------------

        public DataTable GetSqlData_f(string Selcmd)
        {
            string Conn = string.Empty;

            if (ExtRealOrgId1.Text == "1B")
            {
                Conn = Conn59;
            }
            else
            {
                Conn = ConnJW;
            }

            DataTable dt = new DataTable();

            using (SqlConnection mySqlConnection = new SqlConnection(Conn))
            {
                try
                {
                    mySqlConnection.Open();
                    SqlCommand mySqlCommand = new SqlCommand(Selcmd, mySqlConnection);
                    SqlDataAdapter mySqlDataAdapter = new SqlDataAdapter(mySqlCommand);
                    mySqlDataAdapter.Fill(dt);
                }
                catch (Exception ex)
                {
                    throw (ex);
                }
                finally
                {
                    mySqlConnection.Close();
                    mySqlConnection.Dispose();
                }

                return dt;
            }
        }

        protected void SQL_Data(string Selcmd)
        {
            string Conn = string.Empty;

            if (ExtRealOrgId1.Text == "1B")
            {
                Conn = Conn59;
            }
            else
            {
                Conn = ConnJW;
            }

            using (SqlConnection connect = new SqlConnection(Conn))
            {
                try
                {
                    connect.Open();
                    SqlCommand cmd = new SqlCommand(Selcmd, connect);
                    int count = cmd.ExecuteNonQuery();
                    cmd.Cancel();
                }
                catch (Exception ex)
                {

                }
                finally
                {
                    connect.Close();
                    connect.Dispose();
                }
            }
        }

        //--------------------------------------------------

        protected void Timer1_Tick(object sender, EventArgs e)
        {
            ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "GetGPS();", true);

            Thread t1 = new Thread(MyBackgroundTask);
            t1.Start();
        }

        protected void MyBackgroundTask()
        {
            string Date = System.DateTime.Now.ToString("yyyy/MM/dd");
            string Time = DateTime.Now.ToString("HH:mm:ss");

            string latitude = this.latitude.Value;
            string longitude = this.longitude.Value;

            if (ExtRealOrgId1.Text != "" && IdNo.Text != "" && latitude != "" && longitude != "")
            {
                string Selcmd = "insert into [Workflow].[dbo].[ETG_SEM_PipeLineInspection_Gps](ExtRealOrgId1, IdNo, Date, Time, Latitude, Longitude) values('" + ExtRealOrgId1.Text + "', '" + IdNo.Text + "', '" + Date + "', '" + Time + "', '" + latitude + "', '" + longitude + "')";
                SQL_Data(Selcmd);
            }
        }
    }
}