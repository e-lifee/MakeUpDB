--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

-- Started on 2022-12-26 18:29:51

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

DROP DATABASE "MakeUpApp";
--
-- TOC entry 3487 (class 1262 OID 24869)
-- Name: MakeUpApp; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "MakeUpApp" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Turkish_Turkey.1254';


ALTER DATABASE "MakeUpApp" OWNER TO postgres;

\connect "MakeUpApp"

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
-- TOC entry 5 (class 2615 OID 24947)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 254 (class 1255 OID 26481)
-- Name: ProductPriceChangingTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."ProductPriceChangingTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW."Product_Price" <> OLD."Product_Price" THEN
        INSERT INTO "ProductPriceChanging"("productNo", "Old_Price", "new_Price", "updateDate")
        VALUES(OLD."Product_id", OLD."Product_Price", NEW."Product_Price", CURRENT_TIMESTAMP::TIMESTAMP);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public."ProductPriceChangingTR1"() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 26415)
-- Name: addRecordTR1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."addRecordTR1"() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW."Supplier_Name" = UPPER(NEW."Supplier_Name"); 
    RETURN NEW;
END;
$$;


ALTER FUNCTION public."addRecordTR1"() OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 26162)
-- Name: add_product_to_cart(character varying, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.add_product_to_cart(cart_id character varying, product_id integer, quantity integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "CartProducts" ("Cart_id", "Product_id", "quantity")
  VALUES (Cart_id, Product_id, quantity);
END;
$$;


ALTER FUNCTION public.add_product_to_cart(cart_id character varying, product_id integer, quantity integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 26094)
-- Name: calculate_order_total(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_order_total(product_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (SELECT SUM("OrderDetails"."Product_Quantity" * "Products"."Product_Price")
          FROM "OrderDetails" 
          INNER JOIN "Products" ON "OrderDetails"."Product_id" = "Products"."Product_id"
          WHERE "Products"."Product_id" = Product_id);
END;
$$;


ALTER FUNCTION public.calculate_order_total(product_id integer) OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 26171)
-- Name: decrement_stock_levels(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrement_stock_levels() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "Products"
  SET "Product_stock" = "Product_stock" - NEW."quantity"
  WHERE "Product_id" = NEW."Product_id";
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.decrement_stock_levels() OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 26160)
-- Name: get_cart_total(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_cart_total(cart_id character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (SELECT SUM("Products"."Product_Price" * "CartProducts"."quantity")
  FROM "CartProducts"
  INNER JOIN "Products"  ON "CartProducts"."Product_id" = "Products"."Product_id"
  WHERE "CartProducts"."Cart_id" = Cart_id);
END;
$$;


ALTER FUNCTION public.get_cart_total(cart_id character varying) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 26164)
-- Name: get_discounted_price(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_discounted_price(product_id integer, discount_percent integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (SELECT "Product_Price" * (1 - (discount_percent / 100.0))
  FROM "Products"
  WHERE "Product_id" = Product_id);
END;
$$;


ALTER FUNCTION public.get_discounted_price(product_id integer, discount_percent integer) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 26167)
-- Name: get_discounted_prices(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_discounted_prices(discount_percent integer) RETURNS TABLE(product_id integer, original_price money, discounted_price money)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT "Product_id", "Product_Price", "Product_Price" * (1 - (discount_percent / 100.0))
  FROM "Products";
END;
$$;


ALTER FUNCTION public.get_discounted_prices(discount_percent integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 26175)
-- Name: increment_stock_levels(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_stock_levels() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE "Products"
  SET "Product_stock" = "Product_stock" + OLD."quantity"
  WHERE "Product_id" = OLD."Product_id";
  RETURN OLD;
END;
$$;


ALTER FUNCTION public.increment_stock_levels() OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 26174)
-- Name: remove_from_cart(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.remove_from_cart(product_id integer, cart_id character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM "CartProducts" WHERE "Product_id" = Product_id AND "Cart_id"=Cart_id;
END;
$$;


ALTER FUNCTION public.remove_from_cart(product_id integer, cart_id character varying) OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 26538)
-- Name: update_order_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_order_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW."Order_Status" = 'Confirmed' AND OLD."Order_Status" = 'Pending' THEN
    UPDATE "Orders" SET "Order_Status" = 'Shipped' WHERE "Order_id" = NEW."Order_id";
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_order_status() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 219 (class 1259 OID 25033)
-- Name: Address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Address" (
    "Country" character varying NOT NULL,
    "City" character varying NOT NULL,
    "District" character varying NOT NULL,
    "Street" character varying NOT NULL,
    "Building_No" integer NOT NULL,
    "Flat_No" integer NOT NULL,
    "Address_id" character varying NOT NULL
);


ALTER TABLE public."Address" OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 25214)
-- Name: Brand; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Brand" (
    "Brand_id" character varying NOT NULL,
    "Brand_Name" character varying NOT NULL,
    "Supplier_id" character varying NOT NULL
);


ALTER TABLE public."Brand" OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 25712)
-- Name: BrandSupplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."BrandSupplier" (
    "Brand_id" character varying NOT NULL,
    "Supplier_id" character varying NOT NULL
);


ALTER TABLE public."BrandSupplier" OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 25021)
-- Name: Cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cart" (
    "Cart_id" character varying NOT NULL
);


ALTER TABLE public."Cart" OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 25695)
-- Name: CartPayment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CartPayment" (
    "Cart_id" character varying NOT NULL,
    "Payment_id" character varying NOT NULL
);


ALTER TABLE public."CartPayment" OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 26122)
-- Name: CartProducts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."CartProducts" (
    "Cart_id" character varying NOT NULL,
    "Product_id" integer NOT NULL,
    quantity integer NOT NULL
);


ALTER TABLE public."CartProducts" OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 26060)
-- Name: Category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Category" (
    "Category_Name" character varying NOT NULL,
    "CategoryID" integer NOT NULL
);


ALTER TABLE public."Category" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 24948)
-- Name: Customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Customers" (
    "Customer_Name" character varying(40) NOT NULL,
    "Customer_Surname" character varying(40) NOT NULL,
    "Customer_id" character varying(10) NOT NULL,
    "Customer_email" character varying NOT NULL,
    "Customer_phone" character varying(30),
    "Address_id" character varying,
    "Cart_id" character varying
);


ALTER TABLE public."Customers" OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 26368)
-- Name: Favorite_Products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Favorite_Products" (
    "FavoriteProduct_id" integer NOT NULL
);


ALTER TABLE public."Favorite_Products" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 25666)
-- Name: OrderDetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."OrderDetails" (
    "Product_Quantity" integer NOT NULL,
    "Product_id" integer NOT NULL,
    "Order_id" character varying NOT NULL
);


ALTER TABLE public."OrderDetails" OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 24961)
-- Name: Orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Orders" (
    "Order_id" character varying(6) NOT NULL,
    "Order_Date" date,
    "Customer_id" character varying NOT NULL,
    "Order_Status" character varying NOT NULL
);


ALTER TABLE public."Orders" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 25043)
-- Name: Payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Payment" (
    "Payment_id" character varying NOT NULL,
    "Payment_Name" character varying
);


ALTER TABLE public."Payment" OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 25634)
-- Name: ProductDetails; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductDetails" (
    "Production_date" date NOT NULL,
    "Brand_id" character varying NOT NULL,
    "Product_id" integer NOT NULL
);


ALTER TABLE public."ProductDetails" OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 26475)
-- Name: ProductPriceChanging; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ProductPriceChanging" (
    "recordNo" integer NOT NULL,
    "productNo" integer NOT NULL,
    "Old_Price" money NOT NULL,
    "new_Price" money NOT NULL,
    "updateDate" timestamp without time zone NOT NULL
);


ALTER TABLE public."ProductPriceChanging" OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 26474)
-- Name: ProductPriceChanging_recordNo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ProductPriceChanging_recordNo_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."ProductPriceChanging_recordNo_seq" OWNER TO postgres;

--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 231
-- Name: ProductPriceChanging_recordNo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ProductPriceChanging_recordNo_seq" OWNED BY public."ProductPriceChanging"."recordNo";


--
-- TOC entry 230 (class 1259 OID 26375)
-- Name: Product_FavoriteProduct; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Product_FavoriteProduct" (
    "FavoriteProduct_id" integer NOT NULL,
    "Product_id" integer NOT NULL,
    "Product_Name" character varying
);


ALTER TABLE public."Product_FavoriteProduct" OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24994)
-- Name: Products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Products" (
    "Product_id" integer NOT NULL,
    "Product_name" character varying(20) NOT NULL,
    "Product_Price" money NOT NULL,
    "Product_stock" integer NOT NULL,
    "Category_id" integer NOT NULL
);


ALTER TABLE public."Products" OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 24993)
-- Name: Products_Product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Products_Product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Products_Product_id_seq" OWNER TO postgres;

--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 216
-- Name: Products_Product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Products_Product_id_seq" OWNED BY public."Products"."Product_id";


--
-- TOC entry 221 (class 1259 OID 25207)
-- Name: Supplier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Supplier" (
    "Supplier_id" character varying NOT NULL,
    "Supplier_Name" character varying NOT NULL,
    "Supplier_phone" character varying NOT NULL,
    "Supplier_Adress" character varying NOT NULL
);


ALTER TABLE public."Supplier" OWNER TO postgres;

--
-- TOC entry 3250 (class 2604 OID 26478)
-- Name: ProductPriceChanging recordNo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductPriceChanging" ALTER COLUMN "recordNo" SET DEFAULT nextval('public."ProductPriceChanging_recordNo_seq"'::regclass);


--
-- TOC entry 3249 (class 2604 OID 24997)
-- Name: Products Product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products" ALTER COLUMN "Product_id" SET DEFAULT nextval('public."Products_Product_id_seq"'::regclass);


--
-- TOC entry 3468 (class 0 OID 25033)
-- Dependencies: 219
-- Data for Name: Address; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Chuncheon', 'Seo-Myeon', 'Harmony-ro', 101, 25, 'E4464');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Chuncheon', 'Dong-Myeon', 'Pung-Mu', 17, 45, 'E4465');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Bromley', 'Art', 10, 5, 'E4400');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Barnett', 'Yellowstone', 11, 6, 'E4401');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Harrow', 'Power', 12, 7, 'E4402');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Redbridge', 'Church', 13, 8, 'E4403');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Greenwich', 'Albrecth', 14, 9, 'E4404');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', ' Merton', 'Skyblue', 15, 10, 'E4405');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'London', 'Enfield', 'Berkeley', 16, 11, 'E4406');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Bristol', 'Henbury', 'Chicken Dinner', 17, 12, 'E4407');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Liverpool', 'Clubmor', 'Dream', 19, 14, 'E4409');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Liverpool', 'Evertone', 'Sea', 20, 15, 'E4410');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK ', 'Liverpool', 'Yew Tree', 'Uber', 21, 16, 'E4411');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Liverpool', 'Belle Vale', 'Camac', 22, 17, 'E4412');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Manchester', 'Bolton', 'Sunset', 23, 18, 'E4413');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Manchester', 'Salford', 'Crown', 24, 19, 'E4414');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Manchester', 'Bury', 'Hope', 25, 20, 'E4415');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Manchester', 'Oldham', 'Park Ave', 26, 21, 'E4416');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Oxford', 'Woodstock', 'Urban', 27, 22, 'E4417');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Bristol', 'SouthMeat', 'Main Street', 18, 13, 'E4408');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Oxford', 'Didcot', 'Ha-Ha Street', 28, 23, 'E4418');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Oxford', 'Thame', 'Anita Street', 29, 24, 'E4419');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Cambridge', 'Ely', 'Mosley Street', 30, 25, 'E4420');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Cambridge', 'Sohan', 'Singapore', 31, 26, 'E4421');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Cambridge', 'Newmarket', 'Paul Kruger', 32, 27, 'E4422');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('UK', 'Cambridge', 'Haverhill', 'Madison', 33, 28, 'E4423');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'New York', 'Brooklyn', 'Cream', 34, 29, 'E4424');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'New York', 'Manhattan', 'Chapel Street', 35, 30, 'E4425');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'New York', 'Bronx', 'Ruby Row', 36, 31, 'E4426');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Washington', 'Spokane', 'Moon', 39, 34, 'E4430');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'San Diego', 'Alta Vista', 'Forest Lane', 40, 35, 'E4427');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'San Diego', 'Carmel Valley', 'Long Street', 41, 36, 'E4428');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Houston', 'Texas', 'Wonderland', 42, 37, 'E4429');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Washington', 'District of Columbia', 'Arch Route', 43, 38, 'E4431');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Boston', 'Massachusetts', 'Earl Row', 44, 39, 'E4432');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Las Vegas', 'Nevada', 'Petal Boulevard', 45, 40, 'E4433');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('USA', 'Miami', 'Florida', 'Lumber Passage', 46, 41, 'E4434');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('FRANCE', 'Paris', 'Lille', 'Fashion', 47, 42, 'E4435');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('FRANCE', 'Paris', 'Nantes', 'Susame Street', 48, 43, 'E4436');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('FRANCE', 'Paris', 'Strasbourg', 'Oxford', 49, 44, 'E4437');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMANY', 'Berlin', 'Postdam', 'Frederich', 50, 45, 'E4438');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMANY', 'Berlin', 'Schönefeld', 'Nichol Angela', 52, 47, 'E4440');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMANY', 'Berlin', 'Oranienburg', 'Pamela', 51, 46, 'E4439');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Daejeon', 'Dong-Gu', 'Sand-Mu', 21, 12, 'E4466');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMANY', 'Bavyera', 'Münih', 'Times Street', 53, 48, 'E4441');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMNAY', 'Brandenburg', 'Postdam', 'Corner Street', 54, 49, 'E4442');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMNAY', 'Hessen', 'Wiesbaden', 'Great Jones', 55, 50, 'E4443');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('GERMANY', 'Schleswig-Holstein', 'Kiel', 'Albert Einstein', 56, 51, 'E4444');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Rome', 'Tivoli', 'Vincent Van Gogh', 57, 52, 'E4445');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Rome', 'Fregene', 'Flowers ', 58, 53, 'E4446');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Milan', 'Pero', 'West Street', 60, 55, 'E4448');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Milan', 'Segrate', 'New Romen', 59, 54, 'E4447');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Venice', 'Padova', 'South Street', 61, 56, 'E4449');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ITALY', 'Venice', 'Treviso', 'Earth Street', 62, 57, 'E4450');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ARGENTINA', 'Rosario', 'North District', 'Canadian ', 63, 58, 'E4451');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ARGENTINA ', 'Buenos Aries', 'Palermo', 'Bacom', 64, 59, 'E4452');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ARGENTINA', 'Santa Fe', 'Rafaela', 'Camel ', 65, 60, 'E4453');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ARGENTINA', 'Santa Fe', 'Vanedo Tuerto', 'Pink Street', 66, 61, 'E4454');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('ARGENTINA', 'Santa Fe', 'Santo Tomé', 'Pascalya', 67, 62, 'E4455');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('BRAZILIAN', 'Acre', 'Rio Branco', 'Zodiac', 68, 63, 'E4456');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('BRAZILIAN', 'Amazon', 'Center', 'Corner', 69, 64, 'E4457');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('CHINA', 'Beijing', 'Miyun ', 'Martha', 70, 65, 'E4458');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('CHINA', 'Beijing', 'Yanqing', 'Poseidon', 1, 1, 'E4459');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('CHINA ', 'Shanghai', 'Minhang', 'Dong Jie', 2, 3, 'E4460');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('CHINA', 'Shanghai', 'Songjang', 'Xiang', 33, 41, 'E4461');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Busan', 'Gijang-Gun', 'Sejong-daero', 12, 81, 'E4462');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Busan', 'Bak-Gu', 'Rodeo-gil', 14, 21, 'E4463');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Daejeon', 'Yuseong-Gu', 'Harmony Street', 15, 34, 'E4467');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Seoul', 'Nowon-Gu', 'Xi Lu', 44, 21, 'E4468');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Seoul', 'Mapo-Gu', 'Da Dao', 13, 14, 'E4469');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Seoul', 'Gangseo-Gu', 'Da Jie', 37, 4, 'E4470');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Seoul', 'Yongsan-Gu', 'Nan-lu', 46, 41, 'E4471');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('KOREA', 'Seoul', 'Gangnam-Gu', 'Zhong Lu', 34, 7, 'E4472');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Ankara', 'Etimesgut', 'Bağlıca', 56, 10, 'E4478');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Ankara', 'Ümitkoy', 'Camsızlar', 1, 1, 'E4477');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Kayseri', 'Yahyalı', 'Yenicami', 7, 16, 'E4481');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'İstanbul', 'Zeytinburnu', 'Sardunya', 5, 21, 'E4473');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'İtanbul', 'Kadıköy', 'Paşabahçe', 76, 3, 'E4474');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'İstanbul', 'Beylikdüzü', 'Hanımeli', 1, 5, 'E4475');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'İstanbul', 'Bebek', 'Samanyolu', 3, 45, 'E4476');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Ankara', 'Çankaya', 'Yeşilkent', 3, 7, 'E4479');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Ankara', 'Sincan', 'Osmaniye', 8, 10, 'E4480');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'Ankara', 'Sincan', 'Armutlu', 1, 1, 'E4487');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'İzmir', 'Konak', 'Pandora', 12, 13, 'E4488');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('TURKEY', 'ADANA', 'Merkez', 'Kışgüneşi', 1, 17, 'E4492');
INSERT INTO public."Address" ("Country", "City", "District", "Street", "Building_No", "Flat_No", "Address_id") VALUES ('FRANCE ', 'Paris', 'Komodo', 'Summertime', 78, 98, 'E4493');


--
-- TOC entry 3471 (class 0 OID 25214)
-- Dependencies: 222
-- Data for Name: Brand; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('101', 'Sephora', '11');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('102', 'Golden Rose', '12');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('103', 'Revolution', '13');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('104', 'Pastel', '15');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('105', 'Flormar', '14');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('106', 'The Balm', '16');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('107', 'AVON', '17');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('108', 'Farmasi', '18');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('109', 'LYKD', '19');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('110', 'Physica Formula', '20');
INSERT INTO public."Brand" ("Brand_id", "Brand_Name", "Supplier_id") VALUES ('100', 'Maybeline ', '10');


--
-- TOC entry 3475 (class 0 OID 25712)
-- Dependencies: 226
-- Data for Name: BrandSupplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('100', '10');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('101', '11');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('102', '12');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('103', '13');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('104', '14');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('105', '15');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('106', '16');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('107', '17');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('108', '18');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('109', '19');
INSERT INTO public."BrandSupplier" ("Brand_id", "Supplier_id") VALUES ('110', '20');


--
-- TOC entry 3467 (class 0 OID 25021)
-- Dependencies: 218
-- Data for Name: Cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810800');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810801');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810802');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810803');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810804');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810805');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810806');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810807');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810808');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810809');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810810');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810811');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810812');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810813');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810814');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810815');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810816');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810817');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810818');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810819');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810820');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810821');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810822');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810823');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810824');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810825');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810826');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810827');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810828');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810829');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810830');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810831');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810832');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810833');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810834');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810836');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810837');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810838');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810839');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810840');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810841');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810842');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810843');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810844');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810845');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810846');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810847');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810848');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810849');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810850');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810851');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810852');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810853');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810854');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810855');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810856');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810857');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810858');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810859');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810860');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810861');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810862');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810863');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810864');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810865');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810866');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810867');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810868');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810869');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810870');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810871');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810872');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810881');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810882');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810879');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810878');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810877');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810876');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810875');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810873');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810880');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810883');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810884');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810885');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810886');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810887');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810888');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810889');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810890');
INSERT INTO public."Cart" ("Cart_id") VALUES ('c1810891');


--
-- TOC entry 3474 (class 0 OID 25695)
-- Dependencies: 225
-- Data for Name: CartPayment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810809', '1044');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810810', '1045');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810811', '1046');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810812', '1047');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810813', '1048');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810814', '1049');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810815', '1050');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810816', '1051');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810817', '1052');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810818', '1053');
INSERT INTO public."CartPayment" ("Cart_id", "Payment_id") VALUES ('c1810819', '1054');


--
-- TOC entry 3477 (class 0 OID 26122)
-- Dependencies: 228
-- Data for Name: CartProducts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810802', 4, 2);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810806', 8, 1);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810801', 5, 2);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810802', 10, 2);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810801', 1, 1);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810802', 9, 3);
INSERT INTO public."CartProducts" ("Cart_id", "Product_id", quantity) VALUES ('c1810807', 1, 7);


--
-- TOC entry 3476 (class 0 OID 26060)
-- Dependencies: 227
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Eye', 1);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Eyebrow', 2);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Lip', 3);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Hair Care', 5);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Foot Care', 6);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Hand Care', 7);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Body Care', 4);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Eyelash', 8);
INSERT INTO public."Category" ("Category_Name", "CategoryID") VALUES ('Skin Care', 9);


--
-- TOC entry 3463 (class 0 OID 24948)
-- Dependencies: 214
-- Data for Name: Customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KAREN', 'SMITH', '11045', 'karenSmith@gmail.com', '+44 4141 1344141', 'E4400', 'c1810800');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('NICOL', 'GREEN', '11046', 'nicol.green@gmail.com', '+44 4169 4565120', 'E4401', 'c1810801');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('LYDIA', 'MARTIN', '11047', 'lydia03martin@gmail.com
', '+44 4142 1375894', 'E4402', 'c1810802');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ALLISON', 'ARGENT', '11048', 'allison.Argent@gmail.com', '+44 4156 1945678', 'E4403', 'c1810803');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('DEREK', ' HALE', '11049', 'derekHale45@gmail.com', '+44 8656 1975264', 'E4404', 'c1810817');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('STILES', 'STILINSKI', '11050', 'stiles38.stilinski@gmail.com', '+44 7145 4976582', 'E4405', 'c1810804');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ADRIAN', 'HARRIS', '11051', 'adrian.hars34@gmail.com', '+44 4556 1234645', 'E4406', 'c1810805');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MARIN', 'MORELL', '11052', 'morell.marin@gmail.com', '+44 2145 1524976', 'E4407', 'c1810806');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CONDRAD', 'FENRIS', '11053', 'fenrisCondrad88@gmail.com', '+44 1240 4537981', 'E4408', 'c1810807');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CORA', 'HYRE', '11054', 'cora.hyre14@gmail.com', '+44 1576 4523107', 'E4409', 'c1810808');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('SCOTT', 'MCCALL', '11055', 'scott.McCall07@gmail.com', '+44 1204 4530128', 'E4410', 'c1810809');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JOSH', 'DIAZ', '11062', 'joshdiaz29@gmail.com', '+44 8520 4521369', 'E4417', 'c1810816');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JORDAN', 'PARRISH', '11057', 'jrdn.parrish66@gmail.com', '+44 5201 4521368', 'E4411', 'c1810810');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ISAAC', 'LAHEY', '11059', 'laheyIsaac04@gmail.com', '+44 2103 5142304', 'E4413', 'c1810812');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JENNIFER', 'BLAKE', '11058', 'jennifer.blake57@gmail.com', '+44 3612 8425136', 'E4412', 'c1810811');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('HENRY', 'OLKY', '11060', 'henry09olky@gmail.com', '+44 5874 4213548', 'E4414', 'c1810813');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('DAVID', 'WHITE', '11063', 'davidWhite@gmail.com', '+44 1245 8214536', 'E4415', 'c1810814');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('DANNY', 'DARACH', '11064', 'danny.darach03@gmail.com', '+44 2175 1243698', 'E4416', 'c1810815');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ELI', 'ENNIS', '11065', 'eli.ennis27@gmail.com', '+44 4215 7894562', 'E4419', 'c1810818');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('TARA', 'RAEKEN', '11066', 'tara89raeken@gmail.com', '+44 7452 1238659', 'E4418', 'c1810819');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ANTONIA', 'GENTRY', '11067', 'antonia.gentry@gmail.com', '+44 2546 2357965', 'E4420', 'c1810820');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('GINNY', 'MILLER', '11068', 'ginny08.miller@gmail.com', '+44 4216 4521039', 'E4421', 'c1810821');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('BRIANNE', 'HOWEY', '11069', 'brianneHowey@gmail.com', '+44 2563 4210356', 'E4422', 'c1810822');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('AUSTIN', 'DECAHLON', '11070', 'austin.decahlon@gmail.com', '+44 8620 4031562', 'E4423', 'c1810823');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('SARA', 'WAISGLASS', '11071', 'sara.waisglass@gmail.com', '+1 708 1110100', 'E4424', 'c1810824');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MAXINE', 'BAKER', '11072', 'maxine05.baker@gmail.com', '+1 123 5623456', 'E4425', 'c1810825');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JOE', 'ZION', '11078', 'joe09.zion@gmail.com', '+1 988 4521630', 'E4431', 'c1810831');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('RAYMOND', 'ABLECK', '11077', 'raymond07ableck@gmail.com', '+1 456 7810255', 'E4430', 'c1810830');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('PAUL', 'RANDOLPH', '11076', 'randlph.paul04@gmail.com', '+1 402 4521639', 'E4429', 'c1810829');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('SCOTT', 'PORTER', '11075', 'scott98.porter@gmail.com', '+1 845 2537546', 'E4428', 'c1810828');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('FELIX', 'MALLARD', '11074', 'felix.mallard@gmail.com', '+1 253 5612348', 'E4427', 'c1810827');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MARCUS', 'WEST', '11073', 'marcus.west66@gmail.com', '+1 145 1203569', 'E4426', 'c1810826');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('NATHAN', 'MITCHELL', '11079', 'nathan.mitchell@gmail.com', '+1 355 1235896', 'E4432', 'c1810832');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MASON', 'TEMPLE', '11080', 'mason09.mitchell@gmail.com', '+1 894 4561230', 'E4433', 'c1810833');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('HUNTER', 'CHEN', '11081', 'hunter44chen@gmail.com', '+1 222 3561248', 'E4434', 'c1810834');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KATIE', 'DOUGLAS', '11082', 'katie.douglas07@gmail.com', ' +33 123 4563897', 'E4435', 'c1810836');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CLARA', 'TYLER', '11085', 'clara64.tyler@gmail.com', '+49 779 3562145', 'E4438', 'c1810839');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CAMELLE', 'SURROPE', '11084', 'surrope.camelle@gmail.com', '+33 265 4231569', 'E4437', 'c1810838');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('EMMA', 'LE''PRAGE', '11083', 'emma.leprage@gmail.com', '+33 265 3536487', 'E4436', 'c1810837');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('BOBBY', 'SINGER', '11086', 'bobby.singer@gmail.com', '+49 561 2368957', 'E4439', 'c1810840');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('DEAN', 'WINCHESTER', '11087', 'dean.winchester47@gmail.com', '+49 569 8945632', 'E4440', 'c1810841');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MARY', 'CAMPBELL', '11088', 'mary.campbell@gmail.com', '+49 865 2356147', 'E4441', 'c1810842');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JESSICA', 'MOORE', '11089', 'mooreJessica@gmail.com', '+49 256 1234956', 'E4442', 'c1810843');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ADRIANNE', 'PALICKI', '11090', 'adrianne.palicki@gmail.com', '+49 789 5613258', 'E4443', 'c1810844');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('VICTOR', 'HENRIKSEN', '11091', 'victor10.henrick@gmail.com', '+49 231 4569852', 'E4444', 'c1810845');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ALONA', 'TAI', '11092', 'alona.tai67@gmail.com', '+49 566 4526398', 'E4445', 'c1810846');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ELLEN', 'HARVELL', '11093', 'ellen.harvell@gmail.com', '+39 456 7894561', 'E4446', 'c1810847');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CHAD', 'LINDBERG', '11094', 'chad09.lindberg@gmail.com', '+39 421 1234567', 'E4447', 'c1810848');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('GABRIEL', 'TIGERMAN', '11095', 'gabriel.tigerman@gmail.com', '+39 985 4561987', 'E4448', 'c1810849');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ANDY', 'GALLAGHER', '11096', 'andy04gallagher@gmail.com', '+39 562 1254639', 'E4449', 'c1810850');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KATHERINE', 'ISABELLE', '11097', 'isabelle.katherine@gmail.com', '+39 456 9563258', 'E4450', 'c1810851');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('AVA', 'WILSON', '11098', 'ava.wilson11@gmail.com', '+39 112 2356897', 'E4451', 'c1810852');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CINDY', 'SHAMPSON', '11099', 'cindyShampson34@gmail.com', '+39 956 6238547', 'E4452', 'c1810853');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('LISA', 'BREADEN', '11100', 'lisa56breaden@gmail.com', '+54 2021 112021', 'E4453', 'c1810854');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('NICHOLAS', 'ELIA', '11101', 'nicholas.elia01@gmail.com', '+54 2022 561235', 'E4454', 'c1810855');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('LAUREN', 'COHAN', '11102', 'laurencohan09@gmail.com', '+54 5213 546897', 'E4455', 'c1810856');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('BELA', 'TALBOT', '11103', 'bela.talbot89@gmail.com', '+54 4596 456879', 'E4456', 'c1810857');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('RUFUS', 'TURNER', '11104', 'rufus.turner56@gmail.com', '+54 5689 894657', 'E4457', 'c1810858');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ANNE', 'CHURLETT', '11105', 'anne.churlett03@gmail.com', '+55 4176 5986235', 'E4458', 'c1810859');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('BILLY', 'ANDREWS', '11106', 'billyAndrews.ba34@gmail.com', '+55 5236 1593578', 'E4459', 'c1810860');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MUICHIRO', 'TOKITO', '11110', 'moichiro.tokito99@gmail.com', '+55 0213 5986741', 'E4464', 'c1810864');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('MITSURI', 'KANROJI', '11109', 'mitsuri.kanroji@gmail.com', '+55 2356 7894562', 'E4463', 'c1810863');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('GIYU', 'TOMIOKA', '11108', 'tomioka.giyu07@gmail.com', '+55 1524 4568972', 'E4462', 'c1810862');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KAGAYA', 'ABUYASKI', '11107', 'kagaya.abuyaski@gmail.com', '+55 5623 4518962', 'E4460', 'c1810861');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('SAE', 'JUNG-HOO', '11111', 'saejungHoo@gmail.com', '+82 4276 1104276', 'E4465', 'c1810865');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('PARK', 'BUNG-SOO', '11112', 'park.bung68@gmail.com', '+82 4375 1208695', 'E4466', 'c1810866');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JI', 'CHANG-WOOK', '11113', 'jichang.wook09@gmail.com', '+82 5698 7514236', 'E4467', 'c1810867');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CHAE', 'YOUNG-SHIN', '11114', 'chae.young78@gmail.com', ' +82 4987 5236189', 'E4468', 'c1810868');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('PARK', 'MIN-YOUNG', '11115', 'parkmin.young@gmail.com', '+82 5698 7845230', 'E4469', 'c1810869');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KIM', 'MOON-HO', '11116', 'kim.moonho@gmail.com', '+82 1234 5689741', 'E4470', 'c1810870');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('YOO', 'JI-TAE', '11117', 'yoo.jiTae@gmail.com', '+82 5623 0456987', 'E4471', 'c1810871');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JO', 'MIN-JA', '11118', 'jomin.09ja@gmail.com', '+82 1238 4562301', 'E4472', 'c1810872');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('JANG', 'MI-KYUNG', '11119', 'kim.mikyung78@gmail.com', '+82 5620 4562389', 'E4473', 'c1810873');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ELİFE', 'EFE', '11120', 'elife.efe824@gmail.com', '+90 531 775 0825', 'E4474', 'c1810883');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ELİF NUR', 'TABAKLI', '11121', 'elif.tabakli37@gmail.com', '+90 555 051 1699', 'E4475', 'c1810875');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('ASUMAN', 'TUGAY', '11122', 'asuman.tugay56@gmail.com', '+90 531 245 7896 ', 'E4476', 'c1810876');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('DİLARA', 'GÜRPINAR', '11123', 'dilara.gurpinar45@gmail.com', '+90 545 943 8965', 'E4477', 'c1810877');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('NURSEL', 'KÖSE', '11124', 'nursel.kose34@gmail.com', '+90 539 592 3154', 'E4478', 'c1810878');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('AHU', 'YAĞTU', '11125', 'ahu.yagtu78@gmail.com', '+90 544 789 4562', 'E4479', 'c1810879');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CANDAN', 'SOYLU', '11126', 'soylu.candan67@gmail.com', '+90 561 561 2356', 'E4480', 'c1810880');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('BURAK', 'TOZKOPARAN', '11128', 'burakTozkoparan.45@gmail.com', '+90 541 456 7895', 'E4461', 'c1810882');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KEZBAN', 'ASLAN', '11129', 'kezban.aslan@icloud.com', '+90 541 456 4155', 'E4481', 'c1810884');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('KAREN', 'SONIA', '11130', 'karenSonia@gmail.com', '+44 4141 1344142', 'E4487', 'c1810887');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('AHMET', 'ÖZEN', '11131', 'ahmet.ozmen@icloud.com', '+90 541 456 2156', 'E4492', 'c1810890');
INSERT INTO public."Customers" ("Customer_Name", "Customer_Surname", "Customer_id", "Customer_email", "Customer_phone", "Address_id", "Cart_id") VALUES ('CENGİZ', 'ARCA', '11132', 'cengiz121@gmail.com', '+90 567 897 6554', 'E4493', 'c1810891');


--
-- TOC entry 3478 (class 0 OID 26368)
-- Dependencies: 229
-- Data for Name: Favorite_Products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (1);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (2);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (3);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (4);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (5);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (6);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (7);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (8);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (9);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (10);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (11);
INSERT INTO public."Favorite_Products" ("FavoriteProduct_id") VALUES (12);


--
-- TOC entry 3473 (class 0 OID 25666)
-- Dependencies: 224
-- Data for Name: OrderDetails; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 1, 'AC1178');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (2, 4, 'AC1179');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 9, 'AZ0987');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 1, 'AC1179');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (3, 15, 'BA1069');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (2, 10, 'BA1296');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (5, 6, 'CD1076');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 7, 'PK8745');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (2, 2, 'PK8745');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 3, 'PK8745');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (2, 11, 'QK0896');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 8, 'QW8745');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (3, 1, 'QW8745');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (2, 6, 'XK6398');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (1, 5, 'YT7452');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (50, 12, 'CD1076');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (30, 13, 'AZ0987');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (21, 14, 'QK0896');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (100, 2, 'YT7452');
INSERT INTO public."OrderDetails" ("Product_Quantity", "Product_id", "Order_id") VALUES (56, 7, 'XK6398');


--
-- TOC entry 3464 (class 0 OID 24961)
-- Dependencies: 215
-- Data for Name: Orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('AK9787', '2022-12-19', '11125', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('AZ0987', '2022-12-22', '11050', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('CV7845', '2022-12-22', '11126', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('AC1178', '2022-12-20', '11046', 'Confirmed');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('BA1296', '2022-12-20', '11045', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('QK0896', '2022-12-23', '11051', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('KZ2345', '2022-12-15', '11126', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('XK6398', '2022-12-26', '11055', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('YT5467', '2022-11-19', '11125', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('AC1179', '2022-12-21', '11047', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('CD1076', '2022-12-22', '11049', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('PK8745', '2022-12-25', '11054', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('QW8745', '2022-12-23', '11052', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('QZ1345', '2022-12-19', '11124', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('YT7452', '2022-12-24', '11053', 'Pending');
INSERT INTO public."Orders" ("Order_id", "Order_Date", "Customer_id", "Order_Status") VALUES ('BA1069', '2022-12-21', '11048', 'Pending');


--
-- TOC entry 3469 (class 0 OID 25043)
-- Dependencies: 220
-- Data for Name: Payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1044', 'Credit-Card');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1045', 'Cash');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1046', 'Credit-Card');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1047', 'Credit-Card');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1048', 'Cash');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1049', 'Cash');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1050', 'Cash');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1051', 'Cash');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1052', 'Credit-Card');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1053', 'Credit-Card');
INSERT INTO public."Payment" ("Payment_id", "Payment_Name") VALUES ('1054', 'Cash');


--
-- TOC entry 3472 (class 0 OID 25634)
-- Dependencies: 223
-- Data for Name: ProductDetails; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-12-21', '100', 1);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-10-08', '101', 2);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-09-09', '102', 3);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-02-20', '103', 4);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-03-20', '104', 5);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-11-20', '105', 6);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-04-20', '106', 7);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-02-20', '107', 8);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-01-20', '108', 9);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-12-02', '109', 10);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-01-20', '110', 11);
INSERT INTO public."ProductDetails" ("Production_date", "Brand_id", "Product_id") VALUES ('2022-03-20', '110', 12);


--
-- TOC entry 3481 (class 0 OID 26475)
-- Dependencies: 232
-- Data for Name: ProductPriceChanging; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."ProductPriceChanging" ("recordNo", "productNo", "Old_Price", "new_Price", "updateDate") VALUES (1, 9, '?500,00', '?200,00', '2022-12-24 00:21:33.922434');
INSERT INTO public."ProductPriceChanging" ("recordNo", "productNo", "Old_Price", "new_Price", "updateDate") VALUES (2, 11, '?50,00', '?750,00', '2022-12-24 03:55:54.925449');
INSERT INTO public."ProductPriceChanging" ("recordNo", "productNo", "Old_Price", "new_Price", "updateDate") VALUES (3, 11, '?750,00', '?987,00', '2022-12-24 11:27:46.089884');


--
-- TOC entry 3479 (class 0 OID 26375)
-- Dependencies: 230
-- Data for Name: Product_FavoriteProduct; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (1, 1, 'Maybeline Lash Sensotinal Sky High Mascara');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (2, 3, 'Bepanthol Lip Balm');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (3, 2, 'Golden Rose Lip Gloss');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (4, 6, 'Farmasi BB Cream');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (5, 10, 'Pantene Hair Cream');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (6, 11, 'Nivea Hand Cream');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (7, 4, 'New well Terracota');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (8, 5, 'LYKD Foundation');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (9, 7, 'Pastel Eyeshadow Palette');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (10, 12, 'MAC lispstick');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (11, 12, 'Maybeline Lipstick');
INSERT INTO public."Product_FavoriteProduct" ("FavoriteProduct_id", "Product_id", "Product_Name") VALUES (12, 11, 'Himalaya Hand Cream');


--
-- TOC entry 3466 (class 0 OID 24994)
-- Dependencies: 217
-- Data for Name: Products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (3, 'Lip Balm', '?75,00', 10000, 3);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (2, 'Lip Gloss', '?100,00', 90000, 3);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (6, 'BB Cream', '?369,00', 150000, 9);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (7, 'Eyeshadow Palette', '?500,00', 40000, 1);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (8, 'Highlighter', '?350,00', 50000, 9);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (12, 'Lipstick', '?600,00', 400000, 3);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (13, 'Eyebrow Stabilizer', '?90,00', 150000, 2);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (14, 'Foot Care Cream', '?180,00', 70000, 6);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (15, 'Body Lotion', '?300,00', 80000, 4);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (16, 'CC Cream', '?200,00', 2000, 9);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (5, 'Foundation', '?400,00', 100, 9);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (10, 'Hair Cream', '?100,00', 99998, 5);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (1, 'Mascara', '?300,00', 59999, 8);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (4, 'Terracota', '?100,00', 20000, 9);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (9, 'Eyeliner', '?200,00', 899997, 1);
INSERT INTO public."Products" ("Product_id", "Product_name", "Product_Price", "Product_stock", "Category_id") VALUES (11, 'Hand Cream', '?987,00', 200000, 7);


--
-- TOC entry 3470 (class 0 OID 25207)
-- Dependencies: 221
-- Data for Name: Supplier; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('11', 'Cosmoclinic', '+89 4561 235698', 'USA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('12', 'Dermo', '+1 4562 789456', 'FRANCE');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('13', 'Cosmela', '+31 4569 123045', 'ARGENTINA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('10', 'T-Soft', '+44 4541 459233', 'UK');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('15', 'Natulique', '+56 5632 102365', 'GERMANY');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('16', 'Cash&Carry', '+63 1234 789652', 'RUSSIA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('17', 'Tikatti', '+78 4521 632015', 'JAPAN');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('18', 'Thalia', '+28 1524 632541', 'THAILAND');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('19', 'Cosmelix', '+1 5236 412536', 'CHINA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('20', 'Investiga', '+55 4520 369874', 'KOREA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('21', 'KOGO', '+06 5236 789654', 'BOLIVIA');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('14', 'Famer', '+90 542 517 9175', 'TURKEY');
INSERT INTO public."Supplier" ("Supplier_id", "Supplier_Name", "Supplier_phone", "Supplier_Adress") VALUES ('22', 'ORKA', '+90 545 378 6789', 'CANADA');


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 231
-- Name: ProductPriceChanging_recordNo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ProductPriceChanging_recordNo_seq"', 3, true);


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 216
-- Name: Products_Product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Products_Product_id_seq"', 5, true);


--
-- TOC entry 3271 (class 2606 OID 25109)
-- Name: Address Address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Address"
    ADD CONSTRAINT "Address_pkey" PRIMARY KEY ("Address_id");


--
-- TOC entry 3287 (class 2606 OID 25728)
-- Name: BrandSupplier BrandSupplier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BrandSupplier"
    ADD CONSTRAINT "BrandSupplier_pkey" PRIMARY KEY ("Supplier_id", "Brand_id");


--
-- TOC entry 3285 (class 2606 OID 25711)
-- Name: CartPayment CartPayment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartPayment"
    ADD CONSTRAINT "CartPayment_pkey" PRIMARY KEY ("Cart_id", "Payment_id");


--
-- TOC entry 3291 (class 2606 OID 26151)
-- Name: CartProducts CartProducts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartProducts"
    ADD CONSTRAINT "CartProducts_pkey" PRIMARY KEY ("Cart_id", "Product_id");


--
-- TOC entry 3283 (class 2606 OID 25682)
-- Name: OrderDetails OrderDetails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "OrderDetails_pkey" PRIMARY KEY ("Order_id", "Product_id");


--
-- TOC entry 3262 (class 2606 OID 24968)
-- Name: Orders Orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "Orders_pkey" PRIMARY KEY ("Order_id");


--
-- TOC entry 3298 (class 2606 OID 26480)
-- Name: ProductPriceChanging PK; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductPriceChanging"
    ADD CONSTRAINT "PK" PRIMARY KEY ("recordNo");


--
-- TOC entry 3281 (class 2606 OID 25665)
-- Name: ProductDetails ProductDetails_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductDetails"
    ADD CONSTRAINT "ProductDetails_pkey" PRIMARY KEY ("Brand_id", "Product_id");


--
-- TOC entry 3295 (class 2606 OID 26395)
-- Name: Product_FavoriteProduct Product_FavoriteProduct_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product_FavoriteProduct"
    ADD CONSTRAINT "Product_FavoriteProduct_pkey" PRIMARY KEY ("FavoriteProduct_id", "Product_id");


--
-- TOC entry 3273 (class 2606 OID 25107)
-- Name: Address unique_Address_Address_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Address"
    ADD CONSTRAINT "unique_Address_Address_id" UNIQUE ("Address_id");


--
-- TOC entry 3279 (class 2606 OID 25220)
-- Name: Brand unique_Brand_Brand_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Brand"
    ADD CONSTRAINT "unique_Brand_Brand_id" PRIMARY KEY ("Brand_id");


--
-- TOC entry 3277 (class 2606 OID 25213)
-- Name: Supplier unique_Brands_Brand_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Supplier"
    ADD CONSTRAINT "unique_Brands_Brand_id" PRIMARY KEY ("Supplier_id");


--
-- TOC entry 3269 (class 2606 OID 25028)
-- Name: Cart unique_Cart_Cart_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cart"
    ADD CONSTRAINT "unique_Cart_Cart_id" PRIMARY KEY ("Cart_id");


--
-- TOC entry 3289 (class 2606 OID 26066)
-- Name: Category unique_Category_CategoryID; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "unique_Category_CategoryID" PRIMARY KEY ("CategoryID");


--
-- TOC entry 3252 (class 2606 OID 24956)
-- Name: Customers unique_Customer_Customer_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "unique_Customer_Customer_email" UNIQUE ("Customer_email");


--
-- TOC entry 3254 (class 2606 OID 24954)
-- Name: Customers unique_Customer_Customer_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "unique_Customer_Customer_id" PRIMARY KEY ("Customer_id");


--
-- TOC entry 3256 (class 2606 OID 25739)
-- Name: Customers unique_Customer_Customer_phone; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "unique_Customer_Customer_phone" UNIQUE ("Customer_phone");


--
-- TOC entry 3258 (class 2606 OID 25138)
-- Name: Customers unique_Customers_Address_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "unique_Customers_Address_id" UNIQUE ("Address_id");


--
-- TOC entry 3260 (class 2606 OID 25140)
-- Name: Customers unique_Customers_Cart_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "unique_Customers_Cart_id" UNIQUE ("Cart_id");


--
-- TOC entry 3293 (class 2606 OID 26374)
-- Name: Favorite_Products unique_Favorite_Products_FavoriteProduct_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Favorite_Products"
    ADD CONSTRAINT "unique_Favorite_Products_FavoriteProduct_id" PRIMARY KEY ("FavoriteProduct_id");


--
-- TOC entry 3265 (class 2606 OID 24965)
-- Name: Orders unique_Orders_Order_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "unique_Orders_Order_id" UNIQUE ("Order_id");


--
-- TOC entry 3275 (class 2606 OID 25049)
-- Name: Payment unique_Payment_Payment_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Payment"
    ADD CONSTRAINT "unique_Payment_Payment_id" PRIMARY KEY ("Payment_id");


--
-- TOC entry 3267 (class 2606 OID 24999)
-- Name: Products unique_Products_Product_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "unique_Products_Product_id" PRIMARY KEY ("Product_id");


--
-- TOC entry 3263 (class 1259 OID 25147)
-- Name: index_Customers_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_Customers_id" ON public."Orders" USING btree ("Customer_id");


--
-- TOC entry 3296 (class 1259 OID 26426)
-- Name: index_Product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_Product_id" ON public."Product_FavoriteProduct" USING btree ("Product_id");


--
-- TOC entry 3319 (class 2620 OID 26172)
-- Name: CartProducts decrement_stock_levels_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER decrement_stock_levels_trigger AFTER INSERT ON public."CartProducts" FOR EACH ROW EXECUTE FUNCTION public.decrement_stock_levels();


--
-- TOC entry 3320 (class 2620 OID 26176)
-- Name: CartProducts increment_stock_levels_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER increment_stock_levels_trigger AFTER DELETE ON public."CartProducts" FOR EACH ROW EXECUTE FUNCTION public.increment_stock_levels();


--
-- TOC entry 3317 (class 2620 OID 26482)
-- Name: Products productPriceChancing; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "productPriceChancing" BEFORE UPDATE ON public."Products" FOR EACH ROW EXECUTE FUNCTION public."ProductPriceChangingTR1"();


--
-- TOC entry 3318 (class 2620 OID 26416)
-- Name: Supplier recordControl; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "recordControl" BEFORE INSERT ON public."Supplier" FOR EACH ROW EXECUTE FUNCTION public."addRecordTR1"();


--
-- TOC entry 3316 (class 2620 OID 26539)
-- Name: Orders update_order_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_order_status AFTER UPDATE ON public."Orders" FOR EACH ROW EXECUTE FUNCTION public.update_order_status();


--
-- TOC entry 3299 (class 2606 OID 25167)
-- Name: Customers Address_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT "Address_fk" FOREIGN KEY ("Address_id") REFERENCES public."Address"("Address_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3303 (class 2606 OID 25253)
-- Name: Brand BrandSupplier_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Brand"
    ADD CONSTRAINT "BrandSupplier_fk" FOREIGN KEY ("Supplier_id") REFERENCES public."Supplier"("Supplier_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3301 (class 2606 OID 25187)
-- Name: Orders CustomerOrder_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Orders"
    ADD CONSTRAINT "CustomerOrder_fk" FOREIGN KEY ("Customer_id") REFERENCES public."Customers"("Customer_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3300 (class 2606 OID 25172)
-- Name: Customers cart_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Customers"
    ADD CONSTRAINT cart_fk FOREIGN KEY ("Cart_id") REFERENCES public."Cart"("Cart_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3310 (class 2606 OID 25722)
-- Name: BrandSupplier lnk_Brand_BrandSupplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BrandSupplier"
    ADD CONSTRAINT "lnk_Brand_BrandSupplier" FOREIGN KEY ("Brand_id") REFERENCES public."Brand"("Brand_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3304 (class 2606 OID 25659)
-- Name: ProductDetails lnk_Brand_ProductDetails; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductDetails"
    ADD CONSTRAINT "lnk_Brand_ProductDetails" FOREIGN KEY ("Brand_id") REFERENCES public."Brand"("Brand_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3308 (class 2606 OID 25700)
-- Name: CartPayment lnk_Cart_CartPayment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartPayment"
    ADD CONSTRAINT "lnk_Cart_CartPayment" FOREIGN KEY ("Cart_id") REFERENCES public."Cart"("Cart_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3312 (class 2606 OID 26138)
-- Name: CartProducts lnk_Cart_CartProducts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartProducts"
    ADD CONSTRAINT "lnk_Cart_CartProducts" FOREIGN KEY ("Cart_id") REFERENCES public."Cart"("Cart_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3302 (class 2606 OID 26067)
-- Name: Products lnk_Category_Products; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Products"
    ADD CONSTRAINT "lnk_Category_Products" FOREIGN KEY ("Category_id") REFERENCES public."Category"("CategoryID") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3314 (class 2606 OID 26384)
-- Name: Product_FavoriteProduct lnk_Favorite_Products_Product_FavoriteProduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product_FavoriteProduct"
    ADD CONSTRAINT "lnk_Favorite_Products_Product_FavoriteProduct" FOREIGN KEY ("FavoriteProduct_id") REFERENCES public."Favorite_Products"("FavoriteProduct_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3306 (class 2606 OID 25676)
-- Name: OrderDetails lnk_Orders_OrderDetails; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "lnk_Orders_OrderDetails" FOREIGN KEY ("Order_id") REFERENCES public."Orders"("Order_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3309 (class 2606 OID 25705)
-- Name: CartPayment lnk_Payment_CartPayment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartPayment"
    ADD CONSTRAINT "lnk_Payment_CartPayment" FOREIGN KEY ("Payment_id") REFERENCES public."Payment"("Payment_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3313 (class 2606 OID 26133)
-- Name: CartProducts lnk_Products_CartProducts; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."CartProducts"
    ADD CONSTRAINT "lnk_Products_CartProducts" FOREIGN KEY ("Product_id") REFERENCES public."Products"("Product_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3307 (class 2606 OID 25671)
-- Name: OrderDetails lnk_Products_OrderDetails; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."OrderDetails"
    ADD CONSTRAINT "lnk_Products_OrderDetails" FOREIGN KEY ("Product_id") REFERENCES public."Products"("Product_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3305 (class 2606 OID 25654)
-- Name: ProductDetails lnk_Products_ProductDetails; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ProductDetails"
    ADD CONSTRAINT "lnk_Products_ProductDetails" FOREIGN KEY ("Product_id") REFERENCES public."Products"("Product_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3315 (class 2606 OID 26389)
-- Name: Product_FavoriteProduct lnk_Products_Product_FavoriteProduct; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Product_FavoriteProduct"
    ADD CONSTRAINT "lnk_Products_Product_FavoriteProduct" FOREIGN KEY ("Product_id") REFERENCES public."Products"("Product_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3311 (class 2606 OID 25717)
-- Name: BrandSupplier lnk_Supplier_BrandSupplier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."BrandSupplier"
    ADD CONSTRAINT "lnk_Supplier_BrandSupplier" FOREIGN KEY ("Supplier_id") REFERENCES public."Supplier"("Supplier_id") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2022-12-26 18:29:51

--
-- PostgreSQL database dump complete
--

