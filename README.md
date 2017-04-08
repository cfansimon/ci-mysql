# CI-MySQL

单元测试配合gitlab-runner使用，MySQL数据跑内存里

## 使用说明

### 环境变量

`MYSQL_DATABASE` 以该名称自动创建一个数据库


## 本地构建
docker build -t ci-mysql:5.5 .