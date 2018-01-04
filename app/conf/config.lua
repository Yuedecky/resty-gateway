return {
	white_list = {
		"^/m1",
		"^/m2",

		"^/index$",
		"^/ask$",
		"^/share$",
		"^/category/[0-9]+$",
		"^/topics/all$",
		"^/topic/[0-9]+/view$",
		"^/topic/[0-9]+/query$",

		"^/comments/all$",

		"^/user/[0-9a-zA-Z-_]+/index$",
		"^/user/[0-9a-zA-z-_]+/topics$",
		"^/user/[0-9a-zA-z-_]+/collects$",
		"^/user/[0-9a-zA-z-_]+/comments$",
		"^/user/[0-9a-zA-z-_]+/follows$",
		"^/user/[0-9a-zA-z-_]+/fans$",
		"^/user/[0-9a-zA-z-_]+/hot_topics$",
		"^/user/[0-9a-zA-z-_]+/like_topics$",
		
		"^/auth/login$", -- login page
		"^/auth/sign_up$", -- sign up page
		"^/about$", -- about page
		"^/error/$" -- error page
	},

	-- 静态模板配置，保持默认不修改即可
	view_config = {
		engine = "tmpl",
		ext = "html",
		views = "./app/views"
	},

	-- 分页时每页条数配置
	page_config = {
		index_topic_page_size = 10, -- 首页每页文章数
		topic_comment_page_size = 20, -- 文章详情页每页评论数
		notification_page_size = 10, -- 通知每页个数
	},

	-- 生成session的secret，请一定要修改此值为一复杂的字符串，用于加密session
	session_secret = "3584827dfed45b40328acb6242bdf13b",
	-- 用于存储密码的盐，请一定要修改此值
	pwd_secret = "salt_secret_for_password",

	mysql = {
		timeout = 5000, -- sec
		connect_config = {
			host = "127.0.0.1",
			port = 3306,
			database = 'seassoon-api-gateway-mysql',
			username = 'root',
			password = 'root@123',
			max_package_size = 1024 * 1024
		},
		pool_config = {
			max_idle_timeout = 20000, -- sec

			pool_size = 100

		}

	},
	redis = {
		port = 6379,
		host = "127.0.0.1",
		maxlockwait = 10000, --sec
		spinlockwait = 10000, --sec
		pool = {
			timeout = 10000, --sec
			size = 200, -- n
		},
		session_prefix = "$seassoon:session:redis_",
		password = "$seassoon:gateway:redis:password$",
		auth = true
	},

	upload_config =  {
		dir = "/data/seassoon-api-gateway-data/static" ---- 文件目录，修改此值时须同时修改nginx配置文件中的$static_files_path值
	},

}