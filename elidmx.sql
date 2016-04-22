-- MySQL dump 10.14  Distrib 5.5.47-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: elidmx
-- ------------------------------------------------------
-- Server version	5.5.47-MariaDB-1ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `elidmx`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `elidmx` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `elidmx`;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'General');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `channel_with_category`
--

DROP TABLE IF EXISTS `channel_with_category`;
/*!50001 DROP VIEW IF EXISTS `channel_with_category`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `channel_with_category` (
  `cid` tinyint NOT NULL,
  `cname` tinyint NOT NULL,
  `cnumber` tinyint NOT NULL,
  `chancategoryid` tinyint NOT NULL,
  `category` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `channels`
--

DROP TABLE IF EXISTS `channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channels` (
  `cid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'channel id, very important as this will be what ties it to everything else (channels are the lowest thing, think an atom)',
  `cname` varchar(25) NOT NULL COMMENT 'human readable name',
  `cnumber` smallint(6) NOT NULL COMMENT 'channel number as in the one sent with the DMX cable (should match up to dimmer pack) does not allow null, if you are moving channels around it is advised you place them into an unused channel number ',
  `chancategoryid` int(11) DEFAULT NULL,
  PRIMARY KEY (`cid`),
  UNIQUE KEY `cname` (`cname`,`cnumber`),
  KEY `chancategoryid` (`chancategoryid`),
  CONSTRAINT `channels_ibfk_1` FOREIGN KEY (`chancategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channels`
--

LOCK TABLES `channels` WRITE;
/*!40000 ALTER TABLE `channels` DISABLE KEYS */;
INSERT INTO `channels` VALUES (1,'Big Left',1,1),(2,'Big Right',2,NULL);
/*!40000 ALTER TABLE `channels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scene_channels`
--

DROP TABLE IF EXISTS `scene_channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scene_channels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sceneid` int(11) NOT NULL COMMENT 'fk scenes sid',
  `channelid` int(11) NOT NULL COMMENT 'fk channels cid',
  `percent` decimal(3,0) DEFAULT NULL COMMENT '100 is full 0 is off null means does not apply',
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_chan_ver_in_sce` (`sceneid`,`channelid`),
  KEY `sceneid` (`sceneid`,`channelid`),
  KEY `channelid` (`channelid`),
  CONSTRAINT `channelid_fk` FOREIGN KEY (`channelid`) REFERENCES `channels` (`cid`) ON DELETE CASCADE,
  CONSTRAINT `sceneid_fk` FOREIGN KEY (`sceneid`) REFERENCES `scenes` (`sid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COMMENT='how channels relate to each scene';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scene_channels`
--

LOCK TABLES `scene_channels` WRITE;
/*!40000 ALTER TABLE `scene_channels` DISABLE KEYS */;
INSERT INTO `scene_channels` VALUES (1,1,1,100),(3,2,2,100);
/*!40000 ALTER TABLE `scene_channels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `scene_channels_full`
--

DROP TABLE IF EXISTS `scene_channels_full`;
/*!50001 DROP VIEW IF EXISTS `scene_channels_full`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `scene_channels_full` (
  `id` tinyint NOT NULL,
  `sceneid` tinyint NOT NULL,
  `channelid` tinyint NOT NULL,
  `percent` tinyint NOT NULL,
  `cid` tinyint NOT NULL,
  `cname` tinyint NOT NULL,
  `cnumber` tinyint NOT NULL,
  `chancategoryid` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `scene_with_category`
--

DROP TABLE IF EXISTS `scene_with_category`;
/*!50001 DROP VIEW IF EXISTS `scene_with_category`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `scene_with_category` (
  `sid` tinyint NOT NULL,
  `sname` tinyint NOT NULL,
  `scenecategoryid` tinyint NOT NULL,
  `category` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `scenes`
--

DROP TABLE IF EXISTS `scenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scenes` (
  `sid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'scene id db identifier',
  `sname` varchar(25) NOT NULL COMMENT 'human readable scene name',
  `scenecategoryid` int(11) DEFAULT NULL,
  PRIMARY KEY (`sid`),
  UNIQUE KEY `sname` (`sname`),
  KEY `scenecategoryid` (`scenecategoryid`),
  CONSTRAINT `scene_cat_fk` FOREIGN KEY (`scenecategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='Sets up scene definitions, channel data in scene_channels table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scenes`
--

LOCK TABLES `scenes` WRITE;
/*!40000 ALTER TABLE `scenes` DISABLE KEYS */;
INSERT INTO `scenes` VALUES (1,'General Wash',1),(2,'Stage Lights',NULL);
/*!40000 ALTER TABLE `scenes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stack_scenes`
--

DROP TABLE IF EXISTS `stack_scenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stack_scenes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stackid` int(11) NOT NULL,
  `sceneid` int(11) NOT NULL,
  `beats` float NOT NULL COMMENT 'how many beats the scene should last for in the stack',
  `stackorder` int(11) NOT NULL COMMENT 'what position in the stack should it occur in',
  `percent` decimal(3,0) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_at_a_time` (`stackid`,`stackorder`),
  KEY `stackid` (`stackid`),
  KEY `sceneid` (`sceneid`),
  CONSTRAINT `scene_stack_fk` FOREIGN KEY (`sceneid`) REFERENCES `scenes` (`sid`) ON DELETE CASCADE,
  CONSTRAINT `stack_fk` FOREIGN KEY (`stackid`) REFERENCES `stacks` (`stid`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stack_scenes`
--

LOCK TABLES `stack_scenes` WRITE;
/*!40000 ALTER TABLE `stack_scenes` DISABLE KEYS */;
INSERT INTO `stack_scenes` VALUES (1,1,1,5,0,100),(3,1,2,5,2,100);
/*!40000 ALTER TABLE `stack_scenes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `stack_scenes_order`
--

DROP TABLE IF EXISTS `stack_scenes_order`;
/*!50001 DROP VIEW IF EXISTS `stack_scenes_order`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stack_scenes_order` (
  `id` tinyint NOT NULL,
  `stackid` tinyint NOT NULL,
  `sceneid` tinyint NOT NULL,
  `beats` tinyint NOT NULL,
  `stackorder` tinyint NOT NULL,
  `percent` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `stack_with_category`
--

DROP TABLE IF EXISTS `stack_with_category`;
/*!50001 DROP VIEW IF EXISTS `stack_with_category`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `stack_with_category` (
  `stid` tinyint NOT NULL,
  `stname` tinyint NOT NULL,
  `stackcategoryid` tinyint NOT NULL,
  `category` tinyint NOT NULL
) ENGINE=MyISAM */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `stacks`
--

DROP TABLE IF EXISTS `stacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stacks` (
  `stid` int(11) NOT NULL AUTO_INCREMENT COMMENT 'stack id',
  `stname` varchar(25) NOT NULL COMMENT 'stack name',
  `stackcategoryid` int(11) DEFAULT NULL,
  PRIMARY KEY (`stid`),
  KEY `stackchannelid` (`stackcategoryid`),
  CONSTRAINT `stack_cat_fk` FOREIGN KEY (`stackcategoryid`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stacks`
--

LOCK TABLES `stacks` WRITE;
/*!40000 ALTER TABLE `stacks` DISABLE KEYS */;
INSERT INTO `stacks` VALUES (1,'Red and Blue',1);
/*!40000 ALTER TABLE `stacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `elidmx`
--

USE `elidmx`;

--
-- Final view structure for view `channel_with_category`
--

/*!50001 DROP TABLE IF EXISTS `channel_with_category`*/;
/*!50001 DROP VIEW IF EXISTS `channel_with_category`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `channel_with_category` AS select `channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid`,`categories`.`category` AS `category` from (`channels` left join `categories` on((`channels`.`chancategoryid` = `categories`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `scene_channels_full`
--

/*!50001 DROP TABLE IF EXISTS `scene_channels_full`*/;
/*!50001 DROP VIEW IF EXISTS `scene_channels_full`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `scene_channels_full` AS select `scene_channels`.`id` AS `id`,`scene_channels`.`sceneid` AS `sceneid`,`scene_channels`.`channelid` AS `channelid`,`scene_channels`.`percent` AS `percent`,`channels`.`cid` AS `cid`,`channels`.`cname` AS `cname`,`channels`.`cnumber` AS `cnumber`,`channels`.`chancategoryid` AS `chancategoryid` from (`scene_channels` left join `channels` on((`channels`.`cid` = `scene_channels`.`channelid`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `scene_with_category`
--

/*!50001 DROP TABLE IF EXISTS `scene_with_category`*/;
/*!50001 DROP VIEW IF EXISTS `scene_with_category`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `scene_with_category` AS select `scenes`.`sid` AS `sid`,`scenes`.`sname` AS `sname`,`scenes`.`scenecategoryid` AS `scenecategoryid`,`categories`.`category` AS `category` from (`scenes` left join `categories` on((`scenes`.`scenecategoryid` = `categories`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `stack_scenes_order`
--

/*!50001 DROP TABLE IF EXISTS `stack_scenes_order`*/;
/*!50001 DROP VIEW IF EXISTS `stack_scenes_order`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `stack_scenes_order` AS select `stack_scenes`.`id` AS `id`,`stack_scenes`.`stackid` AS `stackid`,`stack_scenes`.`sceneid` AS `sceneid`,`stack_scenes`.`beats` AS `beats`,`stack_scenes`.`stackorder` AS `stackorder`,`stack_scenes`.`percent` AS `percent` from `stack_scenes` order by `stack_scenes`.`stackorder` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `stack_with_category`
--

/*!50001 DROP TABLE IF EXISTS `stack_with_category`*/;
/*!50001 DROP VIEW IF EXISTS `stack_with_category`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `stack_with_category` AS select `stacks`.`stid` AS `stid`,`stacks`.`stname` AS `stname`,`stacks`.`stackcategoryid` AS `stackcategoryid`,`categories`.`category` AS `category` from (`stacks` left join `categories` on((`stacks`.`stackcategoryid` = `categories`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-04-23  9:09:04
