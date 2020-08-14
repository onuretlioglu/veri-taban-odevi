package com.company;

import java.sql.SQLException;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) throws SQLException {
        Baglanti baglanti = new Baglanti();


        System.out.println("Hosgeldiniz lutfen giris yapiniz");
        //  kullaniciGiris.dogrula();


        Scanner sc = new Scanner(System.in);
        int menusecim = 0;

        baglanti.dogrula();

        while(menusecim != 6)
        {   System.out.println("\n1-Tum Urunler");
            System.out.println("2-Urun Ekle");
            System.out.println("3-Urun Guncelle");
            System.out.println("4-Urun Ara");
            System.out.println("5-Urun Sil");
            System.out.println("6-Cikis");

            menusecim = sc.nextInt();
            switch (menusecim){
                case 1:
                    baglanti.tumUrunler();
                    break;

                case 2:
                    baglanti.urunEkle();
                    break;

                case 3:
                    baglanti.urunGuncelle();
                    break;

                case 4:
                    baglanti.urunAra();
                    break;

                case 5:
                    baglanti.urunSil();
                    break;

                case 6:
                    break;
            }
        }



    }
}
