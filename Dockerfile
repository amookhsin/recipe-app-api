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
#	# مجموعه‌ابزار موردنیاز برای کامپایل فایل‌های ترجمه
#	gettext \
#	# Pillow: یه پودمان پایتونی برای کار با فایل
#	build-base jpeg-dev zlib-dev

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
