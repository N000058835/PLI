using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Timers;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using System.Net;
using System.Net.Mail;

namespace PLI
{
    public partial class GPS : System.Web.UI.Page
    {
        private string ConnJW = "Data Source=10.153.196.28; Database=Workflow; User Id=sa; Password=`1qaz2wsx; Connect Timeout=30";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                //ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "GetGPS();", true);

                string Latitude = "22.70604994256049,22.60604994256049,22.65604994256049";
                string Longitude = "120.33608285895309,120.23608285895309,120.28608285895309";

                ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "tinyMap", "tinyMap('" + Latitude + "','" + Longitude + "');", true);
            }
        }

        protected void GpsButton_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "alert", "GetGPS();", true);
        }

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

            if (latitude != "" && longitude != "")
            {
                string Selcmd = "insert into [Workflow].[dbo].[ETG_SEM_PipeLineInspection_Gps](Date, Time, Latitude, Longitude) values('" + Date + "', '" + Time + "', '" + latitude + "', '" + longitude + "')";
                SQL_Data(Selcmd);
            }
        }

        protected void SQL_Data(string Selcmd)
        {
            string Conn = ConnJW;

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

        protected void testMail()
        {
            var fromAddress = new MailAddress("tim760121@gmail.com", "N000141636");
            var toAddress = new MailAddress("sgao0107@gmail.com", "N000136710");
            const string fromPassword = "e04su3su;6";
            const string subject = "竹子";
            const string body = "身體";

            var smtp = new SmtpClient
            {
                Host = "smtp.gmail.com",
                Port = 587,
                EnableSsl = true,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(fromAddress.Address, fromPassword)
            };

            using (var message = new MailMessage(fromAddress, toAddress)
            {
                Subject = subject,
                Body = body
            })
            {
                smtp.Send(message);
            }
        }

        protected void MailBtn_Click(object sender, EventArgs e)
        {
            testMail();
        }

        //--------------------------------------------------

        protected void MapBtn_Click(object sender, EventArgs e)
        {
            map.Style.Add("display", "block");
            DataTable dt = new DataTable();
            string Selcmd = "select Latitude, Longitude from [Workflow].[dbo].[ETG_SEM_PLI_CJHS_Gps] where [HumanId]='N000141636' and Date='2015/05/11' order by Time";
            dt = GetSqlData_f(Selcmd);

            //string Latitude = "22.70604994256049,22.60604994256049,22.65604994256049";
            //string Longitude = "120.33608285895309,120.23608285895309,120.28608285895309";
            string Latitude = string.Empty;
            string Longitude = string.Empty;

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i + 1 == dt.Rows.Count)
                {
                    Latitude += dt.Rows[i]["Latitude"].ToString();
                    Longitude += dt.Rows[i]["Longitude"].ToString();
                }
                else
                {
                    Latitude += dt.Rows[i]["Latitude"].ToString() + ",";
                    Longitude += dt.Rows[i]["Longitude"].ToString() + ",";
                }
            }

            ScriptManager.RegisterClientScriptBlock(this.Page, this.Page.GetType(), "tinyMap", "tinyMap('" + Latitude + "','" + Longitude + "');", true);
        }

        public DataTable GetSqlData_f(string Selcmd)
        {
            DataTable dt = new DataTable();

            using (SqlConnection mySqlConnection = new SqlConnection(ConnJW))
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
    }
}