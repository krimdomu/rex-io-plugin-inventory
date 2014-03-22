--
-- Table structure for table `bios`
--

DROP TABLE IF EXISTS `bios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hardware_id` int(11) DEFAULT NULL,
  `biosdate` datetime DEFAULT NULL,
  `version` varchar(50) DEFAULT NULL,
  `ssn` varchar(150) DEFAULT NULL,
  `manufacturer` varchar(150) DEFAULT NULL,
  `model` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bios`
--

LOCK TABLES `bios` WRITE;
/*!40000 ALTER TABLE `bios` DISABLE KEYS */;
/*!40000 ALTER TABLE `bios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `harddrive`
--

DROP TABLE IF EXISTS `harddrive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `harddrive` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hardware_id` int(11) DEFAULT NULL,
  `devname` varchar(50) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `vendor` varchar(150) DEFAULT NULL,
  `serial` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `harddrive`
--

LOCK TABLES `harddrive` WRITE;
/*!40000 ALTER TABLE `harddrive` DISABLE KEYS */;
/*!40000 ALTER TABLE `harddrive` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `memory`
--

DROP TABLE IF EXISTS `memory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `memory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hardware_id` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `bank` int(11) DEFAULT NULL,
  `serialnumber` varchar(255) DEFAULT NULL,
  `speed` varchar(50) DEFAULT NULL,
  `type` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `memory`
--

LOCK TABLES `memory` WRITE;
/*!40000 ALTER TABLE `memory` DISABLE KEYS */;
/*!40000 ALTER TABLE `memory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `network_adapter`
--

DROP TABLE IF EXISTS `network_adapter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `network_adapter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hardware_id` int(11) NOT NULL,
  `dev` varchar(50) NOT NULL DEFAULT 'eth0',
  `proto` varchar(50) NOT NULL DEFAULT 'dhcp',
  `ip` bigint(20) DEFAULT NULL,
  `netmask` bigint(20) DEFAULT NULL,
  `broadcast` bigint(20) DEFAULT NULL,
  `network` bigint(20) DEFAULT NULL,
  `gateway` bigint(20) DEFAULT NULL,
  `mac` varchar(50) DEFAULT NULL,
  `boot` int(2) DEFAULT NULL,
  `virtual` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `network_adapter`
--

LOCK TABLES `network_adapter` WRITE;
/*!40000 ALTER TABLE `network_adapter` DISABLE KEYS */;
/*!40000 ALTER TABLE `network_adapter` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `processor`
--

DROP TABLE IF EXISTS `processor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `processor` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hardware_id` int(11) DEFAULT NULL,
  `modelname` varchar(150) DEFAULT NULL,
  `vendor` varchar(150) DEFAULT NULL,
  `flags` varchar(150) DEFAULT NULL,
  `mhz` int(11) DEFAULT NULL,
  `cache` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB CHARACTER SET utf8 ;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `processor`
--

LOCK TABLES `processor` WRITE;
/*!40000 ALTER TABLE `processor` DISABLE KEYS */;
/*!40000 ALTER TABLE `processor` ENABLE KEYS */;
UNLOCK TABLES;
