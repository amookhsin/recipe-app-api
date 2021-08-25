# گام‌به‌گام داکرسازی جنگو، پیکریدن پستگرس (Postgres) و برپاییدن درهمش پایسته

آغازیدن یه پروژه‌ی جدید RESTFul دو سرویسی (برکا و پایگاه‌داده) با داکر و خودکاریدن فرایندهای توسعه با TravisCI

## داکرسازی و شروعیدن پروژه

برای داکرسازی پروژه گام‌های زیر بترتیب انجام شود.

### تعریفیدن محیط توسعه

تعریفیدن محیط توسعه‌ی برکایمان (app) در فایل `Dockerfile` در ریشه‌ی پروژه همانند زیر:

```Dockerfile
# امیج پایه
ARG PYTHON=3.9
FROM python:${PYTHON}-alpine

# آرگومان‌ها
ARG USERNAME=appuser
ARG UID=1000
ARG WORKDIR=/home/${USERNAME}/app

# متغیرهای محیطی
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# نیازمندی‌ها
RUN apk add --update --no-cache \
    # psycopg2: یه پودمان پایتونی برای پستگرس‌کیوال
    postgresql-dev gcc python3-dev musl-dev
    # # مجموعه‌ابزار موردنیاز برای کامپایل فایل‌های ترجمه
    # gettext \
    # # Pillow: یه پودمان پایتونی برای کار با فایل
    # build-base jpeg-dev zlib-dev

# وابستگی‌ها
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# ایجادیدن کاربر ناریشه
RUN addgroup -S ${USERNAME} -g ${UID} && \
    adduser -u ${UID} -G ${USERNAME} -D ${USERNAME}
USER ${USERNAME}

# پوشه‌کاری
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

# رونشتن پروژه
COPY . .

# درگاه
EXPOSE 8000

# دستور آغارین
CMD ["python", "manage.py", "runserver 0.0.0.0:8000"]
```

### تعریفیدن وابستگی‌ها

تعریفیدن وابستگی‌های برکایمان (app) در فایل `requirements.txt` در ریشه‌ی پروژه همانند زیر:

```txt
Django>=3.2.6,<3.3.0
djangorestframework>=3.12.4,<3.13.0
psycopg2>=2.9.1,<2.10.0
flake8>=3.9.2,<3.10.0
```

### تعریفیدن سرویس‌ها

تعریفیدن سرویس‌هایی که برکایمان را تشکیل می‌دهند در فایل `docker-compose.yml` در ریشه‌ی پروژه همانند زیر:

```yml
version: "3.8"
services:
  server:
    build:
      context: ./
      dockerfile: Dockerfile
      args:
        - PYTHON=3.8
        - USERNAME=appuser
        - UID=1001
        - WORKDIR=/home/appuser/app
    environment:
      - DEBUG=${DEBUG}
      - SECRET_KEY=${SECRET_KEY}
      - ALLOWED_HOSTS=${ALLOWED_HOSTS}
      - DB_HOST=${POSTGRES_HOST}
      - DB_PORT=${POSTGRES_PORT}
      - DB_USER=${POSTGRES_USER}
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_NAME=${POSTGRES_DB}
    ports:
      - "3014:5000"
    volumes:
      - "./server:/home/appuser/app"
    command: >
      sh -c "python manage.py migrate && python manage.py runserver 0.0.0.0:5000"
    depends_on:
      - db

  pgadmin:
    image: dpage/pgadmin4:5
    restart: always
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
    depends_on:
      - db
    ports:
      - "3015:80"
  db:
    image: postgres:alpine
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
```

#### تعریفیدن متغیرهای محلی

تعریفیدن متغیرهای محلی در فایل `.env` در ریشه‌ی پروژه همانند زیر:

```env
# کلید امنیتی برکا
DEBUG=1
SECRET_KEY=rd6x9istgpbn+4(74d@+ce@du#+vz+(fpjgqi0o$bv4g!_ulox
ALLOWED_HOSTS=localhost 127.0.0.1 [::1]

# پستگرس‌کیوال
POSTGRES_USER=admin
POSTGRES_PASSWORD=password
POSTGRES_DB=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432

# pgAdmin
PGADMIN_DEFAULT_EMAIL=admin@email.com
PGADMIN_DEFAULT_PASSWORD=password
```

### ساختن ایمیج‌ها

برای ساختن ایمیج‌ها دستور زیر در خط‌فرمان در ریشه پروژه اجراییده شود:

```bash
docker-compose build
```

### شروعیدن پروژه

اجرای دستور زیر در خط فرمان در ریشه پروژه:

```bash
docker-compose run --rm server sh -c "django-admin.py startproject my_project ."
```

#### تعریفیدن مقررات نحوشناسی

تعریفیدن مقرارات نحوشناسی در فایل `.flake8` در پوشه‌ی `server` در ریشه‌ی پروژه همانند زیر:

```flake8
[flake8]
    max-line-length = 119
    exclude =
        migrations,
        settings.py,
        manage.py,
```

## پیکریدن پستگرس

افزودن کدهای زیر در فایل `settings.py` برکایمان:

```python
import os
from django.core.exceptions import ImproperlyConfigured

# ...

class env:
    """convert env values to currect types"""
    @staticmethod
    def _get_key(key, default=None):
        try:
            return str(os.environ.get(key))
        except KeyError:
            if default is not None:
                return default
            else:
                raise ImproperlyConfigured(f'Set the {key} environment variable')

    @staticmethod
    def bool(key, default=None):
        truethy = ('true', 't', "1")
        return bool(env._get_key(key, default).lower() in truethy)

    @staticmethod
    def str(key, default=None):
        return env._get_key(key, default)

    @staticmethod
    def integer(key, default=None):
        return int(env._get_key(key, default))

# ... 

# Database
# https://docs.djangoproject.com/en/3.2/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': env.str('DB_NAME', 'postgres'),
        'USER': env.str('DB_USER', 'admin'),
        'PASSWORD': env.str('DB_PASSWORD', 'password'),
        'HOST': env.str('DB_HOST', 'db'),
        'PORT': env.str('DB_PORT', '5432'),
    }
}

# ...
```

## برپاییدن درهمش پایسته

تعریفیدن دستورهایی که به‌شکل خودکار پس از هربار push در مخزن پروژه باید توسط TravisCI اجرا شوند، در فایل `.travis.yml` در ریشه‌ی پروژه همانند زیر:

```yml
language: python
python:
  - "3.8"

services: 
  - docker

before_script: pip install docker-compose

script:
  - docker-compose run server sh -c "python manage.py test && flake8"
```

### پیونداندن مخزن پروژه به TravisCI

1. ساخت حساب در [گیت‌لب][1] /[گیت‌هاب][2] و [TravisCI][3]
2. کامیت گرفتن از پروژه و push کردن در مخزن‌اش
3. پیونداندن مخزن پروژه به TravisCI برای اجرای فرایندهای توسعه‌ی خودکار و تعریفیدن متغیرهای محلی

## اجراییدن پروژه

1. اجراییدن دستود زیر در خط فرمان در مسیر ریشه‌ی پروژه:

    <div dir="ltr" align="left" markdown="1">

    ```shell
    docker-compose up
    ```

    </div>

2. دیدن صفحه آغازین جنگو در مسیر زیر:

    <div dir="ltr" align="left" markdown="1">

    ```txt
    http://localhost:3014/
    ```

    </div>

[1]: https://gitlab.com/
[2]: https://github.com/
[3]: https://travis-ci.com/
