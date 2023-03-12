using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace WindowsFormsApp3
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }
        NpgsqlConnection connect = new NpgsqlConnection("server=localHost;port=5432;UserId=postgres;" +
           "password=54484238e;database=edb");
        private void button1_Click(object sender, EventArgs e)
        {
            string query = "select * from \"Supplier\";";
            NpgsqlDataAdapter adapt = new NpgsqlDataAdapter(query, connect);
            DataSet ds = new DataSet();
            adapt.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void button4_Click(object sender, EventArgs e)
        {
            connect.Open();
            NpgsqlCommand command1 = new NpgsqlCommand("delete from \"Supplier\" where \"Supplier_id\"=@supplier_id", connect);
            command1.Parameters.AddWithValue("@supplier_id", textBox1.Text);
            command1.ExecuteNonQuery();
            connect.Close();
            MessageBox.Show("Supplier delete operation has been done successfully.");
        }

        private void button2_Click(object sender, EventArgs e)
        {
            connect.Open();
            NpgsqlCommand command1 = new NpgsqlCommand("insert into \"Supplier\" values(@supplier_id,@supplier_name,@supplier_phone,@supplier_address)", connect);
            command1.Parameters.AddWithValue("@supplier_id", textBox1.Text);
            command1.Parameters.AddWithValue("@supplier_name", textBox2.Text);
            command1.Parameters.AddWithValue("@supplier_phone", textBox3.Text);
            command1.Parameters.AddWithValue("@supplier_address", textBox4.Text);
            command1.ExecuteNonQuery();
            connect.Close();
            MessageBox.Show("Supplier insert operation has been done successfully.");


        }

        private void button3_Click(object sender, EventArgs e)
        {
            connect.Open();
            NpgsqlCommand command1 = new NpgsqlCommand("update \"Supplier\" set \"Supplier_Adress\"=@supplier_address where \"Supplier_id\"=@supplier_id", connect);
            command1.Parameters.AddWithValue("@supplier_id", textBox1.Text);
            command1.Parameters.AddWithValue("@supplier_name", textBox2.Text);
            command1.Parameters.AddWithValue("@supplier_phone", textBox3.Text);
            command1.Parameters.AddWithValue("@supplier_address", textBox4.Text);
            command1.ExecuteNonQuery();
            connect.Close();
            MessageBox.Show("Supplier update operation has been done successfully.");
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }
    }
}
