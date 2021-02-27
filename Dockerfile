# معرفی امیج پایه
ARG PYTHON=3.8
FROM python:${PYTHON}-alpine

# مقداردهی متغیرهای محیطی
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# نصب نیازمندی‌ها
# RUN apk add --update --no-cache \
#	# مجموعه‌ابزار موردنیاز برای کامپایل فایل‌های ترجمه
#	gettext \
#	# psycopg2: یه پودمان پایتونی برای پستگرس‌کیوال
#	postgresql-dev gcc python3-dev musl-dev \
#	# Pillow: یه پودمان پایتونی برای کار با فایل
#	build-base jpeg-dev zlib-dev

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