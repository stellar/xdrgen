test:
	docker run --rm -v $$PWD:/wd -w /wd ruby:3.3 /bin/bash -c '\
		bundle install && \
		bundle exec rspec \
	'

console:
	docker run -it --rm -v $$PWD:/wd -w /wd ruby:3.3 /bin/bash -c '\
		bundle install && \
		bash \
	'
