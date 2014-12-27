#!/usr/bin/env python
# encoding: utf-8

import requests  # install it with PIP


def main():
    """Send coap requests through proxy."""

    proxies = {
        "http": "http://192.168.1.15:8080",
    }

    requests.get("http://[fec0::4]:61616/rl", proxies=proxies)

if __name__ == '__main__':
    main()
