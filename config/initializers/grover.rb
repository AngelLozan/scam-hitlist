Grover.configure  do  |config|
	config.options  =  {
		user_agent:  'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
		emulate_media:  'screen',
		bypass_csp:  true,
		media_features:  [{  name:  'prefers-color-scheme',  value:  'dark'  }],
		vision_deficiency:  'deuteranopia',
		extra_http_headers:  {  'Accept-Language':  'en-US'  },
		cache:  false,
		timeout:  0,  # Timeout in ms. A value of `0` means 'no timeout'
		launch_args:  ['--font-render-hinting=medium'],
		wait_until:  'domcontentloaded',
    executable_path: "google-chrome"
	}
end
