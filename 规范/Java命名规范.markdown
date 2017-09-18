# 模块命名规范
**有什么建议请写在这里**
~~~

~~~
~~~
**建议请写在这上面，不要超过当前位置**
~~~



**项目基本命名规范**
~~~
项目前缀： micro-ticket
      eg: micro-ticket
          micro-ticket-config
~~~
~~~
项目子项目： mt前缀+子项目-功能
      eg: 订单子项目
          接口定义:mtorder-api
          服务定义:mtorder-service
          消费定义:mtorder-ui

      eg: 支付子项目
          接口定义:mtpay-api
          服务定义:mtpay-service
          消费定义:mtpay-ui

项目公共模块：
    <modules>
        <-- 公共子项目 -->
        <module>config-server</module>
        <module>eureka-server</module>
        <module>hystrix-dashboard</module>
        <module>hystrix-turbine</module>
        <module>monitor-server</module>
        
        <-- 支付子项目 -->
        <module>mtpay-api</module>
        <module>mtpay-service</module>
        <module>mtpay-ui</module>

        <-- 订单子项目 -->
        <module>mtorder-api</module>
        <module>mtorder-service</module>
        <module>mtorder-ui</module>
    </modules>
~~~

**模块包命名规范**
~~~
项目基本包： org.igetwell.ticket
~~~

~~~
子项目基本包： 项目基本包+子项目标识
子项目功能包： 项目基本包+子项目标识+功能标识
      eg: 订单子项目
          基本包:org.igetwell.ticket.mtorder
          功能包:
                org.igetwell.ticket.mtorder.api
                org.igetwell.ticket.mtorder.service
                org.igetwell.ticket.mtorder.ui

      eg: 支付子项目
          基本包:org.igetwell.ticket.mtpay
          功能包:
                org.igetwell.ticket.mtpay.api
                org.igetwell.ticket.mtpay.service
                org.igetwell.ticket.mtpay.ui
~~~
~~~
模块业务包：
    model    实体层、Bean、Entity
    dao      Dao层、Mapper
    vo       Vo组合实体类
    zuul     Zuul层
    web      控制器
    domain   Service层(定义,接口以I开头命名)
    conf     配置文件、常量、过滤器、拦截器、Servlet、工具类
        property
        servlet
        filter
        utils
        listener
        persistence
        interceptor
        annotation

      eg: 订单子模块业务
          Api基本包:
              org.igetwell.ticket.mtorder.api
              org.igetwell.ticket.mtorder.api.conf    
              org.igetwell.ticket.mtorder.api.entity
              org.igetwell.ticket.mtorder.api.domain
              org.igetwell.ticket.mtorder.api.vo
          Service基本包:
              org.igetwell.ticket.mtorder.service
              org.igetwell.ticket.mtorder.service.dao
              org.igetwell.ticket.mtorder.service.domain
              org.igetwell.ticket.mtorder.service.conf
              org.igetwell.ticket.mtorder.service.vo
          UI基本包:
              org.igetwell.ticket.mtorder.ui
              org.igetwell.ticket.mtorder.ui.web

      eg: 支付子模块业务
          Api基本包:
              org.igetwell.ticket.mtpay.api
              org.igetwell.ticket.mtpay.api.conf
              org.igetwell.ticket.mtpay.api.entity
              org.igetwell.ticket.mtpay.api.domain
              org.igetwell.ticket.mtpay.api.vo
          Service基本包:
              org.igetwell.ticket.mtpay.service
              org.igetwell.ticket.mtpay.service.dao
              org.igetwell.ticket.mtpay.service.domain
              org.igetwell.ticket.mtpay.service.conf
              org.igetwell.ticket.mtpay.service.vo
          UI基本包:
              org.igetwell.ticket.mtpay.ui
              org.igetwell.ticket.mtpay.ui.web

~~~

**目录命名规范**
~~~

~~~








