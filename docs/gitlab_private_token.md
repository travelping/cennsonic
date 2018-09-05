# Gitlab Private Token

Gitlab Private Token is needed to access files of a repository directly without
need to clone it or to be signed in on the Gitlab portal. Therefore if you see
a link containing "private_token" in the query, for example:

```
https://gitlab.tpip.net/aalferov/cennsonic/raw/master/README.md?private_token=$PRIVATE_TOKEN
```

that assumes token based authentication to access the file directly and the
$PRIVATE_TOKEN environment variable is set to a token value.

Please follow the [Personal Access Tokens] guide to get yourself one,
and make sure you have selected the "API" scope during the token creation.

<!-- Links -->

[Personal Access Tokens]: https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html
