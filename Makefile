.PHONY: behat db

null:
	@echo -n "No task given!"

up:
	docker-compose up

install:
	docker-compose run --rm php-cli bash -c "chmod +x /var/install.sh && /var/install.sh"

update:
	docker-compose run --rm php-cli bash -c "chmod +x /var/update.sh && /var/update.sh"

bash:
	docker-compose run --rm php-cli bash

db:
	docker-compose exec TEMPLATE bash -c "/var/www/TEMPLATE/bin/console doctrine:schema:update --force"

coverage:
	docker-compose exec TEMPLATE bash -c "cd /var/www/TEMPLATE/; phpdbg -qrr -d memory_limit=-1 ./vendor/bin/phpunit --coverage-html build/"
