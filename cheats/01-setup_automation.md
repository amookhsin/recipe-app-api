# آغازیدن یه پروژه‌ی جدید

آغازیدن یه پروژه‌ی جدید RESTFul دو سرویسی (برکا و پایگاه‌داده) با داکر و خودکاریدن فرایندهای توسعه با TravisCI

## داکرسازی

### تعریفیدن محیط توسعه

تعریفیدن محیط توسعه‌ی برکایمان (app) در فایل `Dockerfile` در ریشه‌ی پروژه همانند زیر:

```Dockerfile
# معرفی امیج پایه
ARG PYTHON=3.8
FROM python:${PYTHON}-alpine

# مقداردهی متغیرهای محیطی
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# نصب نیازمندی‌ها
# RUN apk add --update --no-cache \
# # مجموعه‌ابزار موردنیاز برای کامپایل فایل‌های ترجمه
# gettext \
# # psycopg2: یه پودمان پایتونی برای پستگرس‌کیوال
# postgresql-dev gcc python3-dev musl-dev \
# # Pillow: یه پودمان پایتونی برای کار با فایل
# build-base jpeg-dev zlib-dev

# نصب وابستگی‌ها
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# تعریف آرگومان‌ها
ARG USERNAME=appuser
ARG UID=1000
ARG WORKDIR=/home/${USERNAME}/app

# ایجاد کاربر: برای پردازش در کانتینر با کاربر ناریشه
RUN addgroup -S ${USERNAME} -g ${UID} && \
    adduser -u ${UID} -G ${USERNAME} -D ${USERNAME}
USER ${USERNAME}

# نهادن پوشه‌ی کاری
RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

# رونوشت از پروژه
COPY . .

# هویدایش درگاه
EXPOSE 8080

# دستور آغارین
CMD ["python", "manage.py", "runserver 0.0.0.0:8080"]
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
        - UID=1000
        - WORKDIR=/home/appuser/app
    environment:
      - DEBUG=${DEBUG}
      - SECRET_KEY=${SECRET_KEY}
      - DB_NAME=${POSTGRES_DB}
      - DB_USER=${POSTGRES_USER}
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_HOST=${POSTGRES_HOST}
      - DB_PORT=${POSTGRES_PORT}
    ports:
      - "3014:5000"
    volumes:
      - "./server:/home/appuser/app"
    command: >
      sh -c "[ -f manage.py ] || \
            django-admin startproject app . && \
            python manage.py runserver 0.0.0.0:5000"
    depends_on:
      - db

  db:
    image: postgres:alpine
```

#### تعریفیدن متغیرهای محلی

تعریفیدن متغیرهای محلی در فایل `.env` در ریشه‌ی پروژه همانند زیر:

```env
# کلید امنیتی برکا
SECRET_KEY=


# پایگاه‌داده
DB_ENGINE=django.db.backends.postgresql
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432
```

## تعریفیدن مقررات نحوشناسی

تعریفیدن مقرارات نحوشناسی در فایل `.flake8` در پوشه‌ی `server` در ریشه‌ی پروژه همانند زیر:

```flake8
[flake8]
    max-line-length = 119
    exclude =
        migrations,
        settings.py,
        manage.py,
```

## تعریفیدن وابستگی‌ها

تعریفیدن وابستگی‌های برکایمان (app) در فایل `requirements.txt` در ریشه‌ی پروژه همانند زیر:

```txt
Django>=2.2.19,<2.3.0
djangorestframework>=3.12.2,<3.13.0
flake8>=3.8.4,<3.9.0
```

## تعریفیدن فرایندهای خودکار

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

## پیوندیدن مخزن پروژه به TravisCI

1. ساخت حساب در [گیت‌لب][1] /[گیت‌هاب][2] و [TravisCI][3]
2. کامیت گرفتن از پروژه و push کردن در مخزن‌اش
3. پیوندیدن مخزن پروژه به TravisCI برای اجرای فرایندهای توسعه‌ی خودکار و تعریفیدن متغیرهای محلی

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
