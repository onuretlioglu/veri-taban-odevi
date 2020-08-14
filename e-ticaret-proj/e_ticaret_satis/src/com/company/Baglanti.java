package com.company;
import java.sql.*;
import java.util.Scanner;

public class Baglanti {
    private Connection baglan() throws SQLException {
        /*** Bağlantı kurulumu **/
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/e-ticaret-db",
                "postgres", "Kocaeli123");
        if (conn != null)
            System.out.println("Veritabanına bağlandı!");
        else
            System.out.println("Bağlantı girişimi başarısız!");

        return conn;
    }

    public void dogrula() throws SQLException {
        Connection conn = baglan();

        String sql= "SELECT * FROM adminler";


        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sql);


        conn.close();

        Scanner sc = new Scanner(System.in);

        String kontrolKullaniciAdi="";
        String kontrolSifre ="";

        int kontrol = 0;

        while(kontrol !=1) {

            System.out.println("Kullanici Adi Giriniz:");
            String kullaniciAdi = sc.next();
            System.out.println("Sifre Giriniz:");
            String sifre = sc.next();


            while(rs.next()) {
                kontrolKullaniciAdi = rs.getString("kullanici_adi");
                kontrolSifre = rs.getString("sifre");


                if (kontrolKullaniciAdi.equals(kullaniciAdi) && kontrolSifre.equals(sifre)) {
                    System.out.println("Dogrulandi");
                    kontrol = 1;
                }

            }

            if(kontrol == 0)
                System.out.println("Hatali sifre");

        }



        rs.close();
        stmt.close();
    }


    public void tumUrunler() throws SQLException {

        Connection conn = baglan();


        String sqll= "SELECT * FROM \"urunler\"";


        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sqll);

        conn.close();

        while(rs.next())
        {

            int urun_id = rs.getInt("id");
            String urun_kategori_id = rs.getString("urun_kategori_id");
            String urun_adi = rs.getString("urun_adi");
            String stok_sayisi = rs.getString("stok_sayisi");

            System.out.println("\n\turun_id : " + urun_id);
            System.out.println("\turun_kategori_id : " + urun_kategori_id);
            System.out.println("\turun_adi : " + urun_adi);
            System.out.println("\tstok_sayisi : " + stok_sayisi);
        }

        rs.close();
        stmt.close();

    }

    public void urunAra() throws SQLException {

        Connection conn = baglan();

        System.out.println("Aranan urun no");
        Scanner sc = new Scanner(System.in);

        String arananUrun = sc.next();

        String sqll= "SELECT * FROM \"urunler\" WHERE \"id\" = "+arananUrun;


        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sqll);


        conn.close();


        while(rs.next())
        {

            int urun_id = rs.getInt("id");
            String urun_kategori_id = rs.getString("urun_kategori_id");
            String urun_adi = rs.getString("urun_adi");
            String stok_sayisi = rs.getString("stok_sayisi");

            System.out.println("\turun_id : " + urun_id);
            System.out.println("\turun_kategori_id : " + urun_kategori_id);
            System.out.println("\turun_adi : " + urun_adi);
            System.out.println("\tstok_sayisi : " + stok_sayisi);
        }

        rs.close();
        stmt.close();

    }

    public void urunGuncelle() throws SQLException {

        String urun_id, degisecek_deger, yeni_deger;
        System.out.println("Kac nolu urun degisecek");
        Scanner sc = new Scanner(System.in);
        urun_id = sc.next();

        System.out.println("Degisecek sutun adi?");
        degisecek_deger = sc.next();
        System.out.println("Yeni Deger: ");
        yeni_deger = sc.next();

        Connection conn = baglan();

        String sql= "UPDATE \"urunler\" SET \"" +degisecek_deger+ "\" = '" +yeni_deger+ "' WHERE \"id\" = " +urun_id;


        Statement stmt = conn.createStatement();
        int sonuc = stmt.executeUpdate(sql);

        if(sonuc == 1)
            System.out.println("Güncelleme basarili");
        else
            System.out.println("islem basarisiz oldu");


        conn.close();


        stmt.close();

    }

    public void urunSil() throws SQLException {

        String urun_id;
        System.out.println("Kac nolu urun silinecek?");

        Scanner sc = new Scanner(System.in);
        urun_id = sc.next();

        Connection conn = baglan();

        String sql= "DELETE FROM \"urunler\" WHERE \"id\" = " +urun_id;


        Statement stmt = conn.createStatement();
        int sonuc = stmt.executeUpdate(sql);

        if(sonuc == 1)
            System.out.println("Silme basarili");
        else
            System.out.println("islem basarisiz oldu");


        conn.close();


        stmt.close();

    }

    public void urunEkle() throws SQLException {

        String  urun_kategori_id,urun_adi, stok_sayisi;
        Scanner sc = new Scanner(System.in);

        System.out.println("urun_adi giriniz :");
        urun_adi = sc.nextLine();
        System.out.println("urun_kategori_id giriniz :");
        urun_kategori_id = sc.nextLine();
        System.out.println("stok sayisi :");
        stok_sayisi = sc.nextLine();


        Connection conn = baglan();

        String sql= "INSERT INTO \"urunler\" (\"urun_adi\", \"urun_kategori_id\", \"stok_sayisi\")" +
                "VALUES ('"+urun_adi+"', '"+urun_kategori_id+"' , '"+stok_sayisi+" ')";


        Statement stmt = conn.createStatement();
        int sonuc = stmt.executeUpdate(sql);

        if(sonuc == 1)
            System.out.println("Ekleme basarili");
        else
            System.out.println("islem basarisiz oldu");


        conn.close();


        stmt.close();

    }
}

