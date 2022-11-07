test:
	podman run -it --rm -v $$PWD:/wd -w /wd ruby /bin/bash -c '\
		bundle install && \
		bundle exec rspec \
	'

console:
	docker run -it --rm -v $$PWD:/wd -w /wd ruby /bin/bash -c '\
		bundle install && \
		bash \
	'
