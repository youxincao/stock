/*
Navicat MySQL Data Transfer

Source Server         : mysql
Source Server Version : 50615
Source Host           : 127.0.0.1:3306
Source Database       : stock

Target Server Type    : MYSQL
Target Server Version : 50615
File Encoding         : 65001

Date: 2013-12-19 14:44:58
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for stock_record
-- ----------------------------
-- DROP TABLE IF EXISTS `stock_record`;
-- CREATE TABLE `stock_record` (
--   `code` varchar(8) NOT NULL,
--   `date` date NOT NULL,
--   `price_begin` float(255,3) NOT NULL,
--   `price_max` float(255,3) NOT NULL,
--   `price_end` float(255,3) NOT NULL,
--   `price_min` float(255,3) NOT NULL,
--   `trade_amount` double(255,0) NOT NULL,
--   `trade_price` double(255,0) NOT NULL,
--   PRIMARY KEY (`date`,`code`),
--   KEY `stock_code` (`code`) USING HASH
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Table structure from stock_info

-- CREATE TABLE `stock_info` (
--        `code`  varchar(8) not NULL ,
--        `name`  varchar(32) not NULL ,
--        `type`  varchar(32) not NULL ,
--        PRIMARY KEY(`code`) 
-- )ENGINE = InnoDB DEFAULT CHARSET=utf8 ;
