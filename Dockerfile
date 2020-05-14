FROM python

COPY bomb.py /
RUN chmod +x bomb.py

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash", "-c", "python3 /bomb.py"]
