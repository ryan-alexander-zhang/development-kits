for f in cert-*.pem; do
  echo "== $f =="
  openssl x509 -in $f -noout -subject -issuer -text | egrep 'Subject:|Issuer:|CA:'
done
