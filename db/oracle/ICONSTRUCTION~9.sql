-- Conéctate como SYSTEM a XEPDB1
sql system@//localhost:1521/XEPDB1
ALTER USER ICONST_DEV IDENTIFIED BY iconst_dev_pwd ACCOUNT UNLOCK;