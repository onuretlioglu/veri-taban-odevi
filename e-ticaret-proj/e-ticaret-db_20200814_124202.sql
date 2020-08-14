--
-- PostgreSQL database dump
--

-- Dumped from database version 12.3
-- Dumped by pg_dump version 12rc1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: kampanya_katilan(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kampanya_katilan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

         UPDATE kampanyalar
         SET katilan_sayisi = katilan_sayisi + 1 WHERE kampanya_id = (SELECT kampanya_id FROM kampanya_musterileri WHERE sonuc_id = 2 AND kampanya_id = NEW.kampanya_id);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kampanya_katilan() OWNER TO postgres;

--
-- Name: kategori_azalt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kategori_azalt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
         UPDATE urun_kategorileri
         SET kategori_urun_sayisi = kategori_urun_sayisi - 1
         where kategori_id = (SELECT urun_kategori_id from urunler WHERE id = NEW.id AND OLD.stok_sayisi - 1 = NEW.stok_sayisi);
 --- (SELECT urun_id from siparisteki_ogeler WHERE siparis_oge_durum_id = 2 AND urun_id = NEW.urun_id);---
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kategori_azalt() OWNER TO postgres;

--
-- Name: oge_durum_degistir(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oge_durum_degistir() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
         UPDATE siparisteki_ogeler
         SET siparis_oge_durum_id = NEW."siparis_durum_id" WHERE siparisteki_ogeler.siparis_id = NEW.siparis_id;
 
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.oge_durum_degistir() OWNER TO postgres;

--
-- Name: siparisara(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.siparisara(aranansiparis integer) RETURNS TABLE(siparisid integer, siparisdurum integer, kargosecenek integer, siparistarih timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "siparis_id", "siparis_durum_id", "kargo_secenek_id", "siparis_verilme_tarihi" FROM musteri_siparisleri
    WHERE "siparis_id" = aranansiparis;
END;
$$;


ALTER FUNCTION public.siparisara(aranansiparis integer) OWNER TO postgres;

--
-- Name: stok_azalt(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.stok_azalt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
         UPDATE urunler
         SET stok_sayisi = stok_sayisi - 1
         where id = (SELECT urun_id from siparisteki_ogeler WHERE siparis_oge_durum_id = 2 AND siparis_id = NEW.siparis_id);
 
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.stok_azalt() OWNER TO postgres;

--
-- Name: tum_urunler(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.tum_urunler() RETURNS TABLE(urunid integer, urunkategori character varying, urunadi character varying, stoksayisi integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "id", urun_kategorileri."kategori_aciklama", "urun_adi", "stok_sayisi" FROM urunler
    INNER JOIN urun_kategorileri ON urunler.urun_kategori_id = urun_kategorileri.kategori_id;
END;
$$;


ALTER FUNCTION public.tum_urunler() OWNER TO postgres;

--
-- Name: urun_ara(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.urun_ara(arananurun integer) RETURNS TABLE(urunid integer, urunkategori integer, urunadi character varying, stoksayisi integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT "id", "urun_kategori_id", "urun_adi", "stok_sayisi" FROM urunler
    WHERE "id" = arananurun;
END;
$$;


ALTER FUNCTION public.urun_ara(arananurun integer) OWNER TO postgres;

--
-- Name: urunler_toplami(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.urunler_toplami(kategoriid integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    toplam NUMERIC;
    urunler RECORD;
BEGIN
    urunler := urun_ara(2);
    toplam := (SELECT SUM(stok_sayisi) FROM urunler WHERE urunler.urunkategori = kategoriid); 

    RETURN  urunler."urunkategori" || E'\t' || toplam;
END
$$;


ALTER FUNCTION public.urunler_toplami(kategoriid integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adminler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adminler (
    kisi_id integer NOT NULL,
    kullanici_adi character varying NOT NULL,
    sifre character varying NOT NULL
);


ALTER TABLE public.adminler OWNER TO postgres;

--
-- Name: adres_tipleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adres_tipleri (
    adres_tip_id integer NOT NULL,
    adres_tip_aciklama character varying NOT NULL
);


ALTER TABLE public.adres_tipleri OWNER TO postgres;

--
-- Name: adres_tipleri_adres_tip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adres_tipleri_adres_tip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adres_tipleri_adres_tip_id_seq OWNER TO postgres;

--
-- Name: adres_tipleri_adres_tip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adres_tipleri_adres_tip_id_seq OWNED BY public.adres_tipleri.adres_tip_id;


--
-- Name: kampanya_musterileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kampanya_musterileri (
    kampanya_id integer NOT NULL,
    musteri_id integer NOT NULL,
    sonuc_id integer NOT NULL
);


ALTER TABLE public.kampanya_musterileri OWNER TO postgres;

--
-- Name: kampanya_sonuclar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kampanya_sonuclar (
    sonuc_id integer NOT NULL,
    sonuc_aciklama character varying NOT NULL
);


ALTER TABLE public.kampanya_sonuclar OWNER TO postgres;

--
-- Name: kampanya_sonuclar_sonuc_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kampanya_sonuclar_sonuc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kampanya_sonuclar_sonuc_id_seq OWNER TO postgres;

--
-- Name: kampanya_sonuclar_sonuc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kampanya_sonuclar_sonuc_id_seq OWNED BY public.kampanya_sonuclar.sonuc_id;


--
-- Name: kampanyalar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kampanyalar (
    kampanya_id integer NOT NULL,
    urun_kategori_id integer NOT NULL,
    kampanya_adi character varying NOT NULL,
    kampanya_baslangic_tarihi timestamp without time zone NOT NULL,
    kampanya_son_tarihi timestamp without time zone NOT NULL,
    "kampanya detaylar" character varying NOT NULL,
    katilan_sayisi integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.kampanyalar OWNER TO postgres;

--
-- Name: kampanyalar_kampanya_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kampanyalar_kampanya_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kampanyalar_kampanya_id_seq OWNER TO postgres;

--
-- Name: kampanyalar_kampanya_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kampanyalar_kampanya_id_seq OWNED BY public.kampanyalar.kampanya_id;


--
-- Name: kargo_secenekleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kargo_secenekleri (
    id integer NOT NULL,
    secenek_aciklamasi character varying NOT NULL,
    ucret integer NOT NULL
);


ALTER TABLE public.kargo_secenekleri OWNER TO postgres;

--
-- Name: kargo_secenekleri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kargo_secenekleri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kargo_secenekleri_id_seq OWNER TO postgres;

--
-- Name: kargo_secenekleri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kargo_secenekleri_id_seq OWNED BY public.kargo_secenekleri.id;


--
-- Name: kisiler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kisiler (
    kisi_id integer NOT NULL,
    kisi_adi character varying NOT NULL,
    kisi_soyadi character varying NOT NULL,
    kisi_tur character(1) NOT NULL
);


ALTER TABLE public.kisiler OWNER TO postgres;

--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kisiler_kisi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.kisiler_kisi_id_seq OWNER TO postgres;

--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kisiler_kisi_id_seq OWNED BY public.kisiler.kisi_id;


--
-- Name: mulk_tipleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mulk_tipleri (
    id integer NOT NULL,
    mulk_tip_aciklama character varying NOT NULL
);


ALTER TABLE public.mulk_tipleri OWNER TO postgres;

--
-- Name: mulk_tipleri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mulk_tipleri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mulk_tipleri_id_seq OWNER TO postgres;

--
-- Name: mulk_tipleri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mulk_tipleri_id_seq OWNED BY public.mulk_tipleri.id;


--
-- Name: mulkler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mulkler (
    mulk_id integer NOT NULL,
    mulk_tip_id integer NOT NULL
);


ALTER TABLE public.mulkler OWNER TO postgres;

--
-- Name: mulkler_mulk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mulkler_mulk_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mulkler_mulk_id_seq OWNER TO postgres;

--
-- Name: mulkler_mulk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mulkler_mulk_id_seq OWNED BY public.mulkler.mulk_id;


--
-- Name: musteri_adresleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri_adresleri (
    musteri_id integer NOT NULL,
    mulk_id integer NOT NULL,
    adres_tip_id integer NOT NULL,
    adres_aciklamasi character varying NOT NULL
);


ALTER TABLE public.musteri_adresleri OWNER TO postgres;

--
-- Name: musteri_siparisleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteri_siparisleri (
    siparis_id integer NOT NULL,
    musteri_id integer NOT NULL,
    siparis_durum_id integer NOT NULL,
    kargo_secenek_id integer NOT NULL,
    siparis_verilme_tarihi timestamp without time zone DEFAULT now() NOT NULL,
    siparis_kargolanma_tarihi timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.musteri_siparisleri OWNER TO postgres;

--
-- Name: musteri_siparisleri_siparis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.musteri_siparisleri_siparis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.musteri_siparisleri_siparis_id_seq OWNER TO postgres;

--
-- Name: musteri_siparisleri_siparis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.musteri_siparisleri_siparis_id_seq OWNED BY public.musteri_siparisleri.siparis_id;


--
-- Name: musteriler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.musteriler (
    kisi_id integer NOT NULL,
    mail character varying NOT NULL,
    telefon character varying NOT NULL,
    odeme_yontemi_no integer NOT NULL
);


ALTER TABLE public.musteriler OWNER TO postgres;

--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.musteriler_musteri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.musteriler_musteri_id_seq OWNER TO postgres;

--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.musteriler_musteri_id_seq OWNED BY public.musteriler.kisi_id;


--
-- Name: odeme_yontemleri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.odeme_yontemleri (
    id integer NOT NULL,
    aciklama character varying NOT NULL
);


ALTER TABLE public.odeme_yontemleri OWNER TO postgres;

--
-- Name: odeme_yontemleri_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.odeme_yontemleri_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.odeme_yontemleri_id_seq OWNER TO postgres;

--
-- Name: odeme_yontemleri_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.odeme_yontemleri_id_seq OWNED BY public.odeme_yontemleri.id;


--
-- Name: siparis_durumu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparis_durumu (
    durum_id integer NOT NULL,
    durum_aciklama character varying NOT NULL
);


ALTER TABLE public.siparis_durumu OWNER TO postgres;

--
-- Name: siparis_durumu_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparis_durumu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparis_durumu_id_seq OWNER TO postgres;

--
-- Name: siparis_durumu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparis_durumu_id_seq OWNED BY public.siparis_durumu.durum_id;


--
-- Name: siparisteki_oge_durum; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparisteki_oge_durum (
    oge_durum_id integer NOT NULL,
    oge_durum_aciklamasi character varying NOT NULL
);


ALTER TABLE public.siparisteki_oge_durum OWNER TO postgres;

--
-- Name: siparisteki_oge_durum_siparis_oge_durum_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparisteki_oge_durum_siparis_oge_durum_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparisteki_oge_durum_siparis_oge_durum_id_seq OWNER TO postgres;

--
-- Name: siparisteki_oge_durum_siparis_oge_durum_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparisteki_oge_durum_siparis_oge_durum_id_seq OWNED BY public.siparisteki_oge_durum.oge_durum_id;


--
-- Name: siparisteki_ogeler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.siparisteki_ogeler (
    oge_id integer NOT NULL,
    siparis_oge_durum_id integer NOT NULL,
    siparis_id integer NOT NULL,
    urun_id integer NOT NULL
);


ALTER TABLE public.siparisteki_ogeler OWNER TO postgres;

--
-- Name: siparisteki_ogeler_oge_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.siparisteki_ogeler_oge_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.siparisteki_ogeler_oge_id_seq OWNER TO postgres;

--
-- Name: siparisteki_ogeler_oge_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.siparisteki_ogeler_oge_id_seq OWNED BY public.siparisteki_ogeler.oge_id;


--
-- Name: urun_kategorileri; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urun_kategorileri (
    kategori_id integer NOT NULL,
    kategori_aciklama character varying NOT NULL,
    kategori_urun_sayisi integer DEFAULT 0
);


ALTER TABLE public.urun_kategorileri OWNER TO postgres;

--
-- Name: urun_kategorileri_kategori_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urun_kategorileri_kategori_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urun_kategorileri_kategori_id_seq OWNER TO postgres;

--
-- Name: urun_kategorileri_kategori_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urun_kategorileri_kategori_id_seq OWNED BY public.urun_kategorileri.kategori_id;


--
-- Name: urunler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.urunler (
    id integer NOT NULL,
    urun_kategori_id integer NOT NULL,
    urun_adi character varying NOT NULL,
    stok_sayisi integer NOT NULL
);


ALTER TABLE public.urunler OWNER TO postgres;

--
-- Name: urunler_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.urunler_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.urunler_id_seq OWNER TO postgres;

--
-- Name: urunler_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.urunler_id_seq OWNED BY public.urunler.id;


--
-- Name: adres_tipleri adres_tip_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres_tipleri ALTER COLUMN adres_tip_id SET DEFAULT nextval('public.adres_tipleri_adres_tip_id_seq'::regclass);


--
-- Name: kampanya_sonuclar sonuc_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_sonuclar ALTER COLUMN sonuc_id SET DEFAULT nextval('public.kampanya_sonuclar_sonuc_id_seq'::regclass);


--
-- Name: kampanyalar kampanya_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanyalar ALTER COLUMN kampanya_id SET DEFAULT nextval('public.kampanyalar_kampanya_id_seq'::regclass);


--
-- Name: kargo_secenekleri id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kargo_secenekleri ALTER COLUMN id SET DEFAULT nextval('public.kargo_secenekleri_id_seq'::regclass);


--
-- Name: kisiler kisi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisiler ALTER COLUMN kisi_id SET DEFAULT nextval('public.kisiler_kisi_id_seq'::regclass);


--
-- Name: mulk_tipleri id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mulk_tipleri ALTER COLUMN id SET DEFAULT nextval('public.mulk_tipleri_id_seq'::regclass);


--
-- Name: mulkler mulk_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mulkler ALTER COLUMN mulk_id SET DEFAULT nextval('public.mulkler_mulk_id_seq'::regclass);


--
-- Name: musteri_siparisleri siparis_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_siparisleri ALTER COLUMN siparis_id SET DEFAULT nextval('public.musteri_siparisleri_siparis_id_seq'::regclass);


--
-- Name: odeme_yontemleri id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odeme_yontemleri ALTER COLUMN id SET DEFAULT nextval('public.odeme_yontemleri_id_seq'::regclass);


--
-- Name: siparis_durumu durum_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis_durumu ALTER COLUMN durum_id SET DEFAULT nextval('public.siparis_durumu_id_seq'::regclass);


--
-- Name: siparisteki_oge_durum oge_durum_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_oge_durum ALTER COLUMN oge_durum_id SET DEFAULT nextval('public.siparisteki_oge_durum_siparis_oge_durum_id_seq'::regclass);


--
-- Name: siparisteki_ogeler oge_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_ogeler ALTER COLUMN oge_id SET DEFAULT nextval('public.siparisteki_ogeler_oge_id_seq'::regclass);


--
-- Name: urun_kategorileri kategori_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun_kategorileri ALTER COLUMN kategori_id SET DEFAULT nextval('public.urun_kategorileri_kategori_id_seq'::regclass);


--
-- Name: urunler id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler ALTER COLUMN id SET DEFAULT nextval('public.urunler_id_seq'::regclass);


--
-- Data for Name: adminler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.adminler VALUES
	(2, 'hasan123', 'h123'),
	(1, 'mehmet123', 'm123'),
	(3, 'kemal123', 'k123');


--
-- Data for Name: adres_tipleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.adres_tipleri VALUES
	(1, 'kargo adresi'),
	(2, 'fatura adresi'),
	(3, 'her ikisi ');


--
-- Data for Name: kampanya_musterileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kampanya_musterileri VALUES
	(1, 5, 2),
	(2, 4, 2),
	(3, 6, 1);


--
-- Data for Name: kampanya_sonuclar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kampanya_sonuclar VALUES
	(5, 'tekrar hatırlat'),
	(4, 'suresi doldu'),
	(3, 'red etti'),
	(2, 'kabul edildi'),
	(1, 'beklemede');


--
-- Data for Name: kampanyalar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kampanyalar VALUES
	(1, 3, 'Bebek bezi indirimi', '2020-03-22 00:00:00', '2020-05-22 00:00:00', '5 bebek bezine %10 indirim.', 2),
	(2, 4, 'Kozmetikte 2 al 1 öde', '2020-03-22 00:00:00', '2020-05-22 00:00:00', '2 üründen birisi hediye.', 4),
	(3, 2, 'Beyaz esyada firsat', '2020-03-22 00:00:00', '2020-05-22 00:00:00', 'Tüm beyaz esyalar %5 indirimli.', 1);


--
-- Data for Name: kargo_secenekleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kargo_secenekleri VALUES
	(1, 'aras-kargo', 11),
	(2, 'yurtici-kargo', 14),
	(3, 'mng-kargo', 9),
	(4, 'xyz-kargo', 10);


--
-- Data for Name: kisiler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.kisiler VALUES
	(1, 'Mehmet', 'Demirkıran', 'A'),
	(2, 'Hasan', 'Polat', 'A'),
	(3, 'Kemal', 'Durmaz', 'A'),
	(4, 'Ali', 'Palabıyık', 'M'),
	(5, 'Alican', 'Aslan', 'M'),
	(6, 'Serhat', 'Sönmez', 'M'),
	(7, 'Salih', 'Babacan', 'M'),
	(8, 'Kemal', 'Selim', 'M'),
	(9, 'Murat', 'Sayılmış', 'M'),
	(10, 'Rasim', 'Durdu', 'M'),
	(11, 'Polat', 'Kadim', 'M');


--
-- Data for Name: mulk_tipleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mulk_tipleri VALUES
	(1, 'ev'),
	(2, 'ofis'),
	(3, 'depo'),
	(4, 'işyeri');


--
-- Data for Name: mulkler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mulkler VALUES
	(1, 2),
	(2, 3),
	(3, 2),
	(4, 1),
	(5, 2),
	(6, 2),
	(7, 4);


--
-- Data for Name: musteri_adresleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri_adresleri VALUES
	(4, 1, 1, 'Merkez Mahallesi'),
	(9, 1, 1, 'Irfan Mahallesi'),
	(7, 2, 3, 'Celal Mahallesi'),
	(6, 2, 3, 'Burnaz Mahallesi'),
	(8, 1, 3, 'Salim Mahallesi'),
	(10, 1, 2, 'Atatürk Mahallesi'),
	(11, 1, 3, 'Barbaros Mahallesi'),
	(5, 2, 2, 'Merkez İşyeri');


--
-- Data for Name: musteri_siparisleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteri_siparisleri VALUES
	(1, 4, 2, 2, '2020-05-13 00:00:00', '2020-08-13 14:00:00'),
	(2, 6, 1, 1, '2020-09-13 17:00:00', '2020-08-15 14:00:00'),
	(3, 7, 1, 3, '2020-11-13 17:30:00', '2020-08-17 14:00:00');


--
-- Data for Name: musteriler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.musteriler VALUES
	(4, 'mail1@gmail.com', '5459584578', 1),
	(5, 'mail2@gmail.com', '5474512356', 2),
	(6, 'mail2@gmail.com', '5455231654', 3),
	(7, 'mail4@gmail.com', '5325641254', 1),
	(8, 'mail5@gmail.com', '5342536598', 2),
	(9, 'mail6@gmail.com', '5411523566', 1),
	(10, 'mail7@gmail.com', '5541256326', 2),
	(11, 'mail8@gmail.com', '5356512154', 3);


--
-- Data for Name: odeme_yontemleri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.odeme_yontemleri VALUES
	(1, 'kredi karti'),
	(2, 'havale'),
	(3, 'eft'),
	(4, 'hediye kartı'),
	(5, 'cüzdan');


--
-- Data for Name: siparis_durumu; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparis_durumu VALUES
	(1, 'kargolandi'),
	(2, 'ödendi'),
	(3, 'iptal edildi');


--
-- Data for Name: siparisteki_oge_durum; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparisteki_oge_durum VALUES
	(5, 'ulaştı'),
	(4, 'iptal edildi'),
	(3, 'kargolandi'),
	(2, 'ödendi'),
	(1, 'beklemede');


--
-- Data for Name: siparisteki_ogeler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.siparisteki_ogeler VALUES
	(1, 2, 1, 1),
	(3, 1, 2, 1),
	(2, 1, 3, 2);


--
-- Data for Name: urun_kategorileri; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.urun_kategorileri VALUES
	(3, 'cocuk', 1500),
	(4, 'kozmetik', 4000),
	(5, 'giyim', 1800),
	(2, 'beyaz-esya', 2000),
	(1, 'elektronik', 1697);


--
-- Data for Name: urunler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.urunler VALUES
	(4, 4, 'Cocuk bezi', 1300),
	(2, 2, 'Vestel no-frost buzdolabi', 400),
	(1, 1, 'Acer 17" laptop', 147),
	(5, 2, 'Arçelik bulaşık makinesi', 150),
	(3, 2, 'Vestel ultra class çamaşır makinesi', 200),
	(6, 2, 'Vestel deneme', 500);


--
-- Name: adres_tipleri_adres_tip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adres_tipleri_adres_tip_id_seq', 3, true);


--
-- Name: kampanya_sonuclar_sonuc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kampanya_sonuclar_sonuc_id_seq', 5, true);


--
-- Name: kampanyalar_kampanya_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kampanyalar_kampanya_id_seq', 3, true);


--
-- Name: kargo_secenekleri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kargo_secenekleri_id_seq', 4, true);


--
-- Name: kisiler_kisi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kisiler_kisi_id_seq', 11, true);


--
-- Name: mulk_tipleri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mulk_tipleri_id_seq', 4, true);


--
-- Name: mulkler_mulk_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mulkler_mulk_id_seq', 7, true);


--
-- Name: musteri_siparisleri_siparis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musteri_siparisleri_siparis_id_seq', 3, true);


--
-- Name: musteriler_musteri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.musteriler_musteri_id_seq', 1, false);


--
-- Name: odeme_yontemleri_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.odeme_yontemleri_id_seq', 5, true);


--
-- Name: siparis_durumu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparis_durumu_id_seq', 2, true);


--
-- Name: siparisteki_oge_durum_siparis_oge_durum_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparisteki_oge_durum_siparis_oge_durum_id_seq', 5, true);


--
-- Name: siparisteki_ogeler_oge_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.siparisteki_ogeler_oge_id_seq', 4, true);


--
-- Name: urun_kategorileri_kategori_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urun_kategorileri_kategori_id_seq', 5, true);


--
-- Name: urunler_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.urunler_id_seq', 6, true);


--
-- Name: adminler adminler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminler
    ADD CONSTRAINT adminler_pkey PRIMARY KEY (kisi_id);


--
-- Name: adres_tipleri adres_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adres_tipleri
    ADD CONSTRAINT adres_tipleri_pkey PRIMARY KEY (adres_tip_id);


--
-- Name: kampanya_musterileri kampanya_musterileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_musterileri
    ADD CONSTRAINT kampanya_musterileri_pkey PRIMARY KEY (kampanya_id, musteri_id);


--
-- Name: kampanya_sonuclar kampanya_sonuclar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_sonuclar
    ADD CONSTRAINT kampanya_sonuclar_pkey PRIMARY KEY (sonuc_id);


--
-- Name: kampanyalar kampanyalar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanyalar
    ADD CONSTRAINT kampanyalar_pkey PRIMARY KEY (kampanya_id);


--
-- Name: kargo_secenekleri kargo_secenekleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kargo_secenekleri
    ADD CONSTRAINT kargo_secenekleri_pkey PRIMARY KEY (id);


--
-- Name: kisiler kisiler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kisiler
    ADD CONSTRAINT kisiler_pkey PRIMARY KEY (kisi_id);


--
-- Name: mulk_tipleri mulk_tipleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mulk_tipleri
    ADD CONSTRAINT mulk_tipleri_pkey PRIMARY KEY (id);


--
-- Name: mulkler mulkler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mulkler
    ADD CONSTRAINT mulkler_pkey PRIMARY KEY (mulk_id);


--
-- Name: musteri_adresleri musteri_adresleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_adresleri
    ADD CONSTRAINT musteri_adresleri_pkey PRIMARY KEY (musteri_id, mulk_id);


--
-- Name: musteri_siparisleri musteri_siparisleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_siparisleri
    ADD CONSTRAINT musteri_siparisleri_pkey PRIMARY KEY (siparis_id);


--
-- Name: musteriler musteriler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteriler
    ADD CONSTRAINT musteriler_pkey PRIMARY KEY (kisi_id);


--
-- Name: odeme_yontemleri odeme_yontemleri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.odeme_yontemleri
    ADD CONSTRAINT odeme_yontemleri_pkey PRIMARY KEY (id);


--
-- Name: siparis_durumu siparis_durumu_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparis_durumu
    ADD CONSTRAINT siparis_durumu_pkey PRIMARY KEY (durum_id);


--
-- Name: siparisteki_oge_durum siparisteki_oge_durum_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_oge_durum
    ADD CONSTRAINT siparisteki_oge_durum_pkey PRIMARY KEY (oge_durum_id);


--
-- Name: siparisteki_ogeler siparisteki_ogeler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_ogeler
    ADD CONSTRAINT siparisteki_ogeler_pkey PRIMARY KEY (oge_id);


--
-- Name: urun_kategorileri urun_kategorileri_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urun_kategorileri
    ADD CONSTRAINT urun_kategorileri_pkey PRIMARY KEY (kategori_id);


--
-- Name: urunler urunler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler
    ADD CONSTRAINT urunler_pkey PRIMARY KEY (id);


--
-- Name: kampanya_musterileri kampanya_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kampanya_trigger AFTER UPDATE ON public.kampanya_musterileri FOR EACH ROW EXECUTE FUNCTION public.kampanya_katilan();


--
-- Name: urunler kategori_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER kategori_trigger AFTER UPDATE ON public.urunler FOR EACH ROW EXECUTE FUNCTION public.kategori_azalt();


--
-- Name: musteri_siparisleri oge_durum_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER oge_durum_trigger AFTER UPDATE ON public.musteri_siparisleri FOR EACH ROW EXECUTE FUNCTION public.oge_durum_degistir();


--
-- Name: siparisteki_ogeler stok_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER stok_trigger AFTER UPDATE ON public.siparisteki_ogeler FOR EACH ROW EXECUTE FUNCTION public.stok_azalt();


--
-- Name: musteri_adresleri adres_tip_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_adresleri
    ADD CONSTRAINT "adres_tip_FK" FOREIGN KEY (adres_tip_id) REFERENCES public.adres_tipleri(adres_tip_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: kampanya_musterileri kampanya_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_musterileri
    ADD CONSTRAINT "kampanya_id_FK" FOREIGN KEY (kampanya_id) REFERENCES public.kampanyalar(kampanya_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: musteri_siparisleri kargo_secenekleri_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_siparisleri
    ADD CONSTRAINT "kargo_secenekleri_FK" FOREIGN KEY (kargo_secenek_id) REFERENCES public.kargo_secenekleri(id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: adminler kisi_admin_cs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adminler
    ADD CONSTRAINT kisi_admin_cs FOREIGN KEY (kisi_id) REFERENCES public.kisiler(kisi_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musteriler kisi_musteri_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteriler
    ADD CONSTRAINT "kisi_musteri_FK" FOREIGN KEY (kisi_id) REFERENCES public.kisiler(kisi_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: musteri_adresleri mulk_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_adresleri
    ADD CONSTRAINT "mulk_id_FK" FOREIGN KEY (mulk_id) REFERENCES public.mulkler(mulk_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: mulkler mulk_tip_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mulkler
    ADD CONSTRAINT "mulk_tip_FK" FOREIGN KEY (mulk_tip_id) REFERENCES public.mulk_tipleri(id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: musteri_adresleri musteri_adres_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_adresleri
    ADD CONSTRAINT "musteri_adres_FK" FOREIGN KEY (musteri_id) REFERENCES public.musteriler(kisi_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: musteri_siparisleri musteri_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_siparisleri
    ADD CONSTRAINT "musteri_id_FK" FOREIGN KEY (musteri_id) REFERENCES public.musteriler(kisi_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: kampanya_musterileri musteri_kampanya_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_musterileri
    ADD CONSTRAINT "musteri_kampanya_FK" FOREIGN KEY (musteri_id) REFERENCES public.musteriler(kisi_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: siparisteki_ogeler musteri_siparis_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_ogeler
    ADD CONSTRAINT "musteri_siparis_FK" FOREIGN KEY (siparis_id) REFERENCES public.musteri_siparisleri(siparis_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: musteriler odeme_musteriler_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteriler
    ADD CONSTRAINT "odeme_musteriler_FK" FOREIGN KEY (odeme_yontemi_no) REFERENCES public.odeme_yontemleri(id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: musteri_siparisleri siparis_durum_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.musteri_siparisleri
    ADD CONSTRAINT "siparis_durum_id_FK" FOREIGN KEY (siparis_durum_id) REFERENCES public.siparis_durumu(durum_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: siparisteki_ogeler siparis_oge_durum_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_ogeler
    ADD CONSTRAINT "siparis_oge_durum_FK" FOREIGN KEY (siparis_oge_durum_id) REFERENCES public.siparisteki_oge_durum(oge_durum_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: kampanya_musterileri sonuc_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kampanya_musterileri
    ADD CONSTRAINT "sonuc_id_FK" FOREIGN KEY (sonuc_id) REFERENCES public.kampanya_sonuclar(sonuc_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: urunler urun_kategori_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.urunler
    ADD CONSTRAINT "urun_kategori_FK" FOREIGN KEY (urun_kategori_id) REFERENCES public.urun_kategorileri(kategori_id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: siparisteki_ogeler urunler_id_FK; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.siparisteki_ogeler
    ADD CONSTRAINT "urunler_id_FK" FOREIGN KEY (urun_id) REFERENCES public.urunler(id) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

