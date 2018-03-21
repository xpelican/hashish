
// cbc-essiv

void aes128_decrypt_cbc (const u32 *ks1, const u32 *in, u32 *out, u32 *essiv, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  aes128_decrypt (ks1, in, out, s_td0, s_td1, s_td2, s_td3, s_td4);

  out[0] ^= essiv[0];
  out[1] ^= essiv[1];
  out[2] ^= essiv[2];
  out[3] ^= essiv[3];

  essiv[0] = in[0];
  essiv[1] = in[1];
  essiv[2] = in[2];
  essiv[3] = in[3];
}

void aes256_decrypt_cbc (const u32 *ks1, const u32 *in, u32 *out, u32 *essiv, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  aes256_decrypt (ks1, in, out, s_td0, s_td1, s_td2, s_td3, s_td4);

  out[0] ^= essiv[0];
  out[1] ^= essiv[1];
  out[2] ^= essiv[2];
  out[3] ^= essiv[3];

  essiv[0] = in[0];
  essiv[1] = in[1];
  essiv[2] = in[2];
  essiv[3] = in[3];
}

void luks_decrypt_sector_aes_cbc_essiv128 (__global u32 *in, u32 *out, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 32; i++)
  {
    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse16 (mk);
  }

  // this one has no AF_sha1_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse16 (mk);
  }

  // this one has no AF_sha256_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse16 (mk);
  }

  // this one has no AF_sha512_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv128_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse16 (mk);
  }

  // this one has no AF_ripemd160_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv256 (__global u32 *in, u32 *out, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 16; i++)
  {
    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }

  // this one has no AF_sha1_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }

  // this one has no AF_sha256_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }

  // this one has no AF_sha512_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_essiv256_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 essiv[4];

  aes256_encrypt (ks2, S, essiv, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }

  // this one has no AF_ripemd160_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, essiv, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

// cbc-plain

void luks_decrypt_sector_aes_cbc_plain128 (__global u32 *in, u32 *out, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 32; i++)
  {
    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse16 (mk);
  }

  // this one has no AF_sha1_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse16 (mk);
  }

  // this one has no AF_sha256_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse16 (mk);
  }

  // this one has no AF_sha512_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse16 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain128_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 32 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 1; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse16 (mk);
  }

  // this one has no AF_ripemd160_diffuse16()

  int idx_mk = 0;

  for (int block = 0; block < 1; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain256 (__global u32 *in, u32 *out, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 16; i++)
  {
    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }

  // this one has no AF_sha1_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }

  // this one has no AF_sha256_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }

  // this one has no AF_sha512_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_cbc_plain256_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }

  // this one has no AF_ripemd160_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_cbc (ks1, data_in, data_out, S, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

// xts-plain

void aes128_decrypt_xts (const u32 *ks1, const u32 *in, u32 *out, u32 *T, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  aes128_decrypt (ks1, out, out, s_td0, s_td1, s_td2, s_td3, s_td4);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  xts_mul2 (T, T);
}

void aes256_decrypt_xts (const u32 *ks1, const u32 *in, u32 *out, u32 *T, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  aes256_decrypt (ks1, out, out, s_td0, s_td1, s_td2, s_td3, s_td4);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  xts_mul2 (T, T);
}

void luks_decrypt_sector_aes_xts_plain256 (__global u32 *in, u32 *out, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 16; i++)
  {
    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse32 (mk);
  }

  // this one has no AF_sha1_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse32 (mk);
  }

  // this one has no AF_sha256_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse32 (mk);
  }

  // this one has no AF_sha512_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain256_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes128_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 16 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 2; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse32 (mk);
  }

  // this one has no AF_ripemd160_diffuse32()

  int idx_mk = 0;

  for (int block = 0; block < 2; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes128_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain512 (__global u32 *in, u32 *out, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in  = 0;
  int idx_out = 0;

  for (int i = 0; i < 8; i++)
  {
    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      out[idx_out++] = data_out[0];
      out[idx_out++] = data_out[1];
      out[idx_out++] = data_out[2];
      out[idx_out++] = data_out[3];
    }
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha1 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse64 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha1_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha1_diffuse64 (mk);
  }

  // this one has no AF_sha1_diffuse64()

  int idx_mk = 0;

  for (int block = 0; block < 4; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha256 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse64 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha256_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha256_diffuse64 (mk);
  }

  // this one has no AF_sha256_diffuse64()

  int idx_mk = 0;

  for (int block = 0; block < 4; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha512 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse64 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_sha512_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_sha512_diffuse64 (mk);
  }

  // this one has no AF_sha512_diffuse64()

  int idx_mk = 0;

  for (int block = 0; block < 4; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_ripemd160 (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse64 (mk);
  }
}

void luks_decrypt_sector_aes_xts_plain512_mk_ripemd160_final (__global u32 *in, u32 *mk, const u32 *ks1, const u32 *ks2, const u32 sector, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 S[4] = { sector, 0, 0, 0 };

  u32 T[4];

  aes256_encrypt (ks2, S, T, s_te0, s_te1, s_te2, s_te3, s_te4);

  int idx_in = 0;

  for (int i = 0; i < 8 - 1; i++)
  {
    int idx_mk = 0;

    for (int block = 0; block < 4; block++)
    {
      u32 data_in[4];

      data_in[0] = in[idx_in++];
      data_in[1] = in[idx_in++];
      data_in[2] = in[idx_in++];
      data_in[3] = in[idx_in++];

      u32 data_out[4];

      aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

      mk[idx_mk++] ^= data_out[0];
      mk[idx_mk++] ^= data_out[1];
      mk[idx_mk++] ^= data_out[2];
      mk[idx_mk++] ^= data_out[3];
    }

    AF_ripemd160_diffuse64 (mk);
  }

  // this one has no AF_ripemd160_diffuse64()

  int idx_mk = 0;

  for (int block = 0; block < 4; block++)
  {
    u32 data_in[4];

    data_in[0] = in[idx_in++];
    data_in[1] = in[idx_in++];
    data_in[2] = in[idx_in++];
    data_in[3] = in[idx_in++];

    u32 data_out[4];

    aes256_decrypt_xts (ks1, data_in, data_out, T, s_td0, s_td1, s_td2, s_td3, s_td4);

    mk[idx_mk++] ^= data_out[0];
    mk[idx_mk++] ^= data_out[1];
    mk[idx_mk++] ^= data_out[2];
    mk[idx_mk++] ^= data_out[3];
  }
}

// luks helper

void luks_af_sha1_then_aes_decrypt (__global luks_t *luks_bufs, __global luks_tmp_t *tmps, u32 *pt_buf, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  const u32 key_size    = luks_bufs->key_size;
  const u32 cipher_mode = luks_bufs->cipher_mode;

  #define BITS_PER_AF (key_size * LUKS_STRIPES)
  #define BITS_PER_SECTOR (512 * 8)
  #define SECTOR_PER_AF (BITS_PER_AF / BITS_PER_SECTOR)
  #define BLOCKS_PER_SECTOR (512 / 16)
  #define OFFSET_PER_BLOCK (16 / 4)
  #define OFFSET_PER_SECTOR (BLOCKS_PER_SECTOR * OFFSET_PER_BLOCK)

  // decrypt AF data and do the AF merge inline

  u32 mk[16] = { 0 };

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv128_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv128_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);
      ukey[4] = swap32_S (tmps->out32[4]);
      ukey[5] = swap32_S (tmps->out32[5]);
      ukey[6] = swap32_S (tmps->out32[6]);
      ukey[7] = swap32_S (tmps->out32[7]);

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv256_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv256_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain128_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain128_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);
      ukey[4] = swap32_S (tmps->out32[4]);
      ukey[5] = swap32_S (tmps->out32[5]);
      ukey[6] = swap32_S (tmps->out32[6]);
      ukey[7] = swap32_S (tmps->out32[7]);

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain256_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain256_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = swap32_S (tmps->out32[0]);
      ukey1[1] = swap32_S (tmps->out32[1]);
      ukey1[2] = swap32_S (tmps->out32[2]);
      ukey1[3] = swap32_S (tmps->out32[3]);

      u32 ukey2[4];

      ukey2[0] = swap32_S (tmps->out32[4]);
      ukey2[1] = swap32_S (tmps->out32[5]);
      ukey2[2] = swap32_S (tmps->out32[6]);
      ukey2[3] = swap32_S (tmps->out32[7]);

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain256_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain256_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = swap32_S (tmps->out32[ 0]);
      ukey1[1] = swap32_S (tmps->out32[ 1]);
      ukey1[2] = swap32_S (tmps->out32[ 2]);
      ukey1[3] = swap32_S (tmps->out32[ 3]);
      ukey1[4] = swap32_S (tmps->out32[ 4]);
      ukey1[5] = swap32_S (tmps->out32[ 5]);
      ukey1[6] = swap32_S (tmps->out32[ 6]);
      ukey1[7] = swap32_S (tmps->out32[ 7]);

      u32 ukey2[8];

      ukey2[0] = swap32_S (tmps->out32[ 8]);
      ukey2[1] = swap32_S (tmps->out32[ 9]);
      ukey2[2] = swap32_S (tmps->out32[10]);
      ukey2[3] = swap32_S (tmps->out32[11]);
      ukey2[4] = swap32_S (tmps->out32[12]);
      ukey2[5] = swap32_S (tmps->out32[13]);
      ukey2[6] = swap32_S (tmps->out32[14]);
      ukey2[7] = swap32_S (tmps->out32[15]);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain512_mk_sha1 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain512_mk_sha1_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }

  // decrypt payload data

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey[4];
      #else
      u32 ukey[4];
      #endif

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv128 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey[8];
      #else
      u32 ukey[8];
      #endif

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey[4];
      #else
      u32 ukey[4];
      #endif

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain128 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey[8];
      #else
      u32 ukey[8];
      #endif

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain256 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey1[4];
      #else
      u32 ukey1[4];
      #endif

      ukey1[0] = mk[0];
      ukey1[1] = mk[1];
      ukey1[2] = mk[2];
      ukey1[3] = mk[3];

      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey2[4];
      #else
      u32 ukey2[4];
      #endif

      ukey2[0] = mk[4];
      ukey2[1] = mk[5];
      ukey2[2] = mk[6];
      ukey2[3] = mk[7];

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey1[8];
      #else
      u32 ukey1[8];
      #endif

      ukey1[0] = mk[ 0];
      ukey1[1] = mk[ 1];
      ukey1[2] = mk[ 2];
      ukey1[3] = mk[ 3];
      ukey1[4] = mk[ 4];
      ukey1[5] = mk[ 5];
      ukey1[6] = mk[ 6];
      ukey1[7] = mk[ 7];

      #if defined (IS_APPLE) && defined (IS_GPU)
      volatile u32 ukey2[8];
      #else
      u32 ukey2[8];
      #endif

      ukey2[0] = mk[ 8];
      ukey2[1] = mk[ 9];
      ukey2[2] = mk[10];
      ukey2[3] = mk[11];
      ukey2[4] = mk[12];
      ukey2[5] = mk[13];
      ukey2[6] = mk[14];
      ukey2[7] = mk[15];

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain512 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
}

void luks_af_sha256_then_aes_decrypt (__global luks_t *luks_bufs, __global luks_tmp_t *tmps, u32 *pt_buf, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  const u32 key_size    = luks_bufs->key_size;
  const u32 cipher_mode = luks_bufs->cipher_mode;

  #define BITS_PER_AF (key_size * LUKS_STRIPES)
  #define BITS_PER_SECTOR (512 * 8)
  #define SECTOR_PER_AF (BITS_PER_AF / BITS_PER_SECTOR)
  #define BLOCKS_PER_SECTOR (512 / 16)
  #define OFFSET_PER_BLOCK (16 / 4)
  #define OFFSET_PER_SECTOR (BLOCKS_PER_SECTOR * OFFSET_PER_BLOCK)

  // decrypt AF data and do the AF merge inline

  u32 mk[16] = { 0 };

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv128_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv128_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);
      ukey[4] = swap32_S (tmps->out32[4]);
      ukey[5] = swap32_S (tmps->out32[5]);
      ukey[6] = swap32_S (tmps->out32[6]);
      ukey[7] = swap32_S (tmps->out32[7]);

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv256_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv256_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain128_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain128_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[0]);
      ukey[1] = swap32_S (tmps->out32[1]);
      ukey[2] = swap32_S (tmps->out32[2]);
      ukey[3] = swap32_S (tmps->out32[3]);
      ukey[4] = swap32_S (tmps->out32[4]);
      ukey[5] = swap32_S (tmps->out32[5]);
      ukey[6] = swap32_S (tmps->out32[6]);
      ukey[7] = swap32_S (tmps->out32[7]);

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain256_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain256_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = swap32_S (tmps->out32[0]);
      ukey1[1] = swap32_S (tmps->out32[1]);
      ukey1[2] = swap32_S (tmps->out32[2]);
      ukey1[3] = swap32_S (tmps->out32[3]);

      u32 ukey2[4];

      ukey2[0] = swap32_S (tmps->out32[4]);
      ukey2[1] = swap32_S (tmps->out32[5]);
      ukey2[2] = swap32_S (tmps->out32[6]);
      ukey2[3] = swap32_S (tmps->out32[7]);

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain256_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain256_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = swap32_S (tmps->out32[ 0]);
      ukey1[1] = swap32_S (tmps->out32[ 1]);
      ukey1[2] = swap32_S (tmps->out32[ 2]);
      ukey1[3] = swap32_S (tmps->out32[ 3]);
      ukey1[4] = swap32_S (tmps->out32[ 4]);
      ukey1[5] = swap32_S (tmps->out32[ 5]);
      ukey1[6] = swap32_S (tmps->out32[ 6]);
      ukey1[7] = swap32_S (tmps->out32[ 7]);

      u32 ukey2[8];

      ukey2[0] = swap32_S (tmps->out32[ 8]);
      ukey2[1] = swap32_S (tmps->out32[ 9]);
      ukey2[2] = swap32_S (tmps->out32[10]);
      ukey2[3] = swap32_S (tmps->out32[11]);
      ukey2[4] = swap32_S (tmps->out32[12]);
      ukey2[5] = swap32_S (tmps->out32[13]);
      ukey2[6] = swap32_S (tmps->out32[14]);
      ukey2[7] = swap32_S (tmps->out32[15]);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain512_mk_sha256 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain512_mk_sha256_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }

  // decrypt payload data

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv128 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain128 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain256 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = mk[0];
      ukey1[1] = mk[1];
      ukey1[2] = mk[2];
      ukey1[3] = mk[3];

      u32 ukey2[4];

      ukey2[0] = mk[4];
      ukey2[1] = mk[5];
      ukey2[2] = mk[6];
      ukey2[3] = mk[7];

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = mk[ 0];
      ukey1[1] = mk[ 1];
      ukey1[2] = mk[ 2];
      ukey1[3] = mk[ 3];
      ukey1[4] = mk[ 4];
      ukey1[5] = mk[ 5];
      ukey1[6] = mk[ 6];
      ukey1[7] = mk[ 7];

      u32 ukey2[8];

      ukey2[0] = mk[ 8];
      ukey2[1] = mk[ 9];
      ukey2[2] = mk[10];
      ukey2[3] = mk[11];
      ukey2[4] = mk[12];
      ukey2[5] = mk[13];
      ukey2[6] = mk[14];
      ukey2[7] = mk[15];

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain512 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
}

void luks_af_sha512_then_aes_decrypt (__global luks_t *luks_bufs, __global luks_tmp_t *tmps, u32 *pt_buf, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  const u32 key_size    = luks_bufs->key_size;
  const u32 cipher_mode = luks_bufs->cipher_mode;

  #define BITS_PER_AF (key_size * LUKS_STRIPES)
  #define BITS_PER_SECTOR (512 * 8)
  #define SECTOR_PER_AF (BITS_PER_AF / BITS_PER_SECTOR)
  #define BLOCKS_PER_SECTOR (512 / 16)
  #define OFFSET_PER_BLOCK (16 / 4)
  #define OFFSET_PER_SECTOR (BLOCKS_PER_SECTOR * OFFSET_PER_BLOCK)

  // move data from out64 to out32

  tmps->out32[ 0] = l32_from_64_S (tmps->out64[0]);
  tmps->out32[ 1] = h32_from_64_S (tmps->out64[0]);
  tmps->out32[ 2] = l32_from_64_S (tmps->out64[1]);
  tmps->out32[ 3] = h32_from_64_S (tmps->out64[1]);
  tmps->out32[ 4] = l32_from_64_S (tmps->out64[2]);
  tmps->out32[ 5] = h32_from_64_S (tmps->out64[2]);
  tmps->out32[ 6] = l32_from_64_S (tmps->out64[3]);
  tmps->out32[ 7] = h32_from_64_S (tmps->out64[3]);
  tmps->out32[ 8] = l32_from_64_S (tmps->out64[4]);
  tmps->out32[ 9] = h32_from_64_S (tmps->out64[4]);
  tmps->out32[10] = l32_from_64_S (tmps->out64[5]);
  tmps->out32[11] = h32_from_64_S (tmps->out64[5]);
  tmps->out32[12] = l32_from_64_S (tmps->out64[6]);
  tmps->out32[13] = h32_from_64_S (tmps->out64[6]);
  tmps->out32[14] = l32_from_64_S (tmps->out64[7]);
  tmps->out32[15] = h32_from_64_S (tmps->out64[7]);

  // decrypt AF data and do the AF merge inline

  u32 mk[16] = { 0 };

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[1]);
      ukey[1] = swap32_S (tmps->out32[0]);
      ukey[2] = swap32_S (tmps->out32[3]);
      ukey[3] = swap32_S (tmps->out32[2]);

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv128_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv128_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[1]);
      ukey[1] = swap32_S (tmps->out32[0]);
      ukey[2] = swap32_S (tmps->out32[3]);
      ukey[3] = swap32_S (tmps->out32[2]);
      ukey[4] = swap32_S (tmps->out32[5]);
      ukey[5] = swap32_S (tmps->out32[4]);
      ukey[6] = swap32_S (tmps->out32[7]);
      ukey[7] = swap32_S (tmps->out32[6]);

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv256_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv256_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = swap32_S (tmps->out32[1]);
      ukey[1] = swap32_S (tmps->out32[0]);
      ukey[2] = swap32_S (tmps->out32[3]);
      ukey[3] = swap32_S (tmps->out32[2]);

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain128_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain128_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = swap32_S (tmps->out32[1]);
      ukey[1] = swap32_S (tmps->out32[0]);
      ukey[2] = swap32_S (tmps->out32[3]);
      ukey[3] = swap32_S (tmps->out32[2]);
      ukey[4] = swap32_S (tmps->out32[5]);
      ukey[5] = swap32_S (tmps->out32[4]);
      ukey[6] = swap32_S (tmps->out32[7]);
      ukey[7] = swap32_S (tmps->out32[6]);

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain256_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain256_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = swap32_S (tmps->out32[1]);
      ukey1[1] = swap32_S (tmps->out32[0]);
      ukey1[2] = swap32_S (tmps->out32[3]);
      ukey1[3] = swap32_S (tmps->out32[2]);

      u32 ukey2[4];

      ukey2[0] = swap32_S (tmps->out32[5]);
      ukey2[1] = swap32_S (tmps->out32[4]);
      ukey2[2] = swap32_S (tmps->out32[7]);
      ukey2[3] = swap32_S (tmps->out32[6]);

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain256_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain256_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = swap32_S (tmps->out32[ 1]);
      ukey1[1] = swap32_S (tmps->out32[ 0]);
      ukey1[2] = swap32_S (tmps->out32[ 3]);
      ukey1[3] = swap32_S (tmps->out32[ 2]);
      ukey1[4] = swap32_S (tmps->out32[ 5]);
      ukey1[5] = swap32_S (tmps->out32[ 4]);
      ukey1[6] = swap32_S (tmps->out32[ 7]);
      ukey1[7] = swap32_S (tmps->out32[ 6]);

      u32 ukey2[8];

      ukey2[0] = swap32_S (tmps->out32[ 9]);
      ukey2[1] = swap32_S (tmps->out32[ 8]);
      ukey2[2] = swap32_S (tmps->out32[11]);
      ukey2[3] = swap32_S (tmps->out32[10]);
      ukey2[4] = swap32_S (tmps->out32[13]);
      ukey2[5] = swap32_S (tmps->out32[12]);
      ukey2[6] = swap32_S (tmps->out32[15]);
      ukey2[7] = swap32_S (tmps->out32[14]);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain512_mk_sha512 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain512_mk_sha512_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }

  // decrypt payload data

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv128 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain128 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain256 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = mk[0];
      ukey1[1] = mk[1];
      ukey1[2] = mk[2];
      ukey1[3] = mk[3];

      u32 ukey2[4];

      ukey2[0] = mk[4];
      ukey2[1] = mk[5];
      ukey2[2] = mk[6];
      ukey2[3] = mk[7];

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = mk[ 0];
      ukey1[1] = mk[ 1];
      ukey1[2] = mk[ 2];
      ukey1[3] = mk[ 3];
      ukey1[4] = mk[ 4];
      ukey1[5] = mk[ 5];
      ukey1[6] = mk[ 6];
      ukey1[7] = mk[ 7];

      u32 ukey2[8];

      ukey2[0] = mk[ 8];
      ukey2[1] = mk[ 9];
      ukey2[2] = mk[10];
      ukey2[3] = mk[11];
      ukey2[4] = mk[12];
      ukey2[5] = mk[13];
      ukey2[6] = mk[14];
      ukey2[7] = mk[15];

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain512 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
}

void luks_af_ripemd160_then_aes_decrypt (__global luks_t *luks_bufs, __global luks_tmp_t *tmps, u32 *pt_buf, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  const u32 key_size    = luks_bufs->key_size;
  const u32 cipher_mode = luks_bufs->cipher_mode;

  #define BITS_PER_AF (key_size * LUKS_STRIPES)
  #define BITS_PER_SECTOR (512 * 8)
  #define SECTOR_PER_AF (BITS_PER_AF / BITS_PER_SECTOR)
  #define BLOCKS_PER_SECTOR (512 / 16)
  #define OFFSET_PER_BLOCK (16 / 4)
  #define OFFSET_PER_SECTOR (BLOCKS_PER_SECTOR * OFFSET_PER_BLOCK)

  // decrypt AF data and do the AF merge inline

  u32 mk[16] = { 0 };

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = tmps->out32[0];
      ukey[1] = tmps->out32[1];
      ukey[2] = tmps->out32[2];
      ukey[3] = tmps->out32[3];

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv128_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv128_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = tmps->out32[0];
      ukey[1] = tmps->out32[1];
      ukey[2] = tmps->out32[2];
      ukey[3] = tmps->out32[3];
      ukey[4] = tmps->out32[4];
      ukey[5] = tmps->out32[5];
      ukey[6] = tmps->out32[6];
      ukey[7] = tmps->out32[7];

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_essiv256_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_essiv256_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = tmps->out32[0];
      ukey[1] = tmps->out32[1];
      ukey[2] = tmps->out32[2];
      ukey[3] = tmps->out32[3];

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain128_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain128_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = tmps->out32[0];
      ukey[1] = tmps->out32[1];
      ukey[2] = tmps->out32[2];
      ukey[3] = tmps->out32[3];
      ukey[4] = tmps->out32[4];
      ukey[5] = tmps->out32[5];
      ukey[6] = tmps->out32[6];
      ukey[7] = tmps->out32[7];

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_cbc_plain256_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_cbc_plain256_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = tmps->out32[0];
      ukey1[1] = tmps->out32[1];
      ukey1[2] = tmps->out32[2];
      ukey1[3] = tmps->out32[3];

      u32 ukey2[4];

      ukey2[0] = tmps->out32[4];
      ukey2[1] = tmps->out32[5];
      ukey2[2] = tmps->out32[6];
      ukey2[3] = tmps->out32[7];

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain256_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain256_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = tmps->out32[ 0];
      ukey1[1] = tmps->out32[ 1];
      ukey1[2] = tmps->out32[ 2];
      ukey1[3] = tmps->out32[ 3];
      ukey1[4] = tmps->out32[ 4];
      ukey1[5] = tmps->out32[ 5];
      ukey1[6] = tmps->out32[ 6];
      ukey1[7] = tmps->out32[ 7];

      u32 ukey2[8];

      ukey2[0] = tmps->out32[ 8];
      ukey2[1] = tmps->out32[ 9];
      ukey2[2] = tmps->out32[10];
      ukey2[3] = tmps->out32[11];
      ukey2[4] = tmps->out32[12];
      ukey2[5] = tmps->out32[13];
      ukey2[6] = tmps->out32[14];
      ukey2[7] = tmps->out32[15];

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      int sector = 0;
      int offset = 0;

      for (sector = 0; sector < SECTOR_PER_AF - 1; sector++, offset += OFFSET_PER_SECTOR)
      {
        luks_decrypt_sector_aes_xts_plain512_mk_ripemd160 (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      }

      luks_decrypt_sector_aes_xts_plain512_mk_ripemd160_final (luks_bufs->af_src_buf + offset, mk, ks1, ks2, sector, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }

  // decrypt payload data

  if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_ESSIV)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 essivhash[8];

      ESSIV_sha256_init128 (ukey, essivhash);

      u32 ks1[44];
      u32 ks2[60];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv128 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 essivhash[8];

      ESSIV_sha256_init256 (ukey, essivhash);

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, essivhash, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_cbc_essiv256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_CBC_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_128)
    {
      u32 ukey[4];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];

      u32 ks1[44];

      aes128_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain128 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey[8];

      ukey[0] = mk[0];
      ukey[1] = mk[1];
      ukey[2] = mk[2];
      ukey[3] = mk[3];
      ukey[4] = mk[4];
      ukey[5] = mk[5];
      ukey[6] = mk[6];
      ukey[7] = mk[7];

      u32 ks1[60];

      aes256_set_decrypt_key (ks1, ukey, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

      luks_decrypt_sector_aes_cbc_plain256 (luks_bufs->ct_buf, pt_buf, ks1, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
  else if (cipher_mode == HC_LUKS_CIPHER_MODE_XTS_PLAIN)
  {
    if (key_size == HC_LUKS_KEY_SIZE_256)
    {
      u32 ukey1[4];

      ukey1[0] = mk[0];
      ukey1[1] = mk[1];
      ukey1[2] = mk[2];
      ukey1[3] = mk[3];

      u32 ukey2[4];

      ukey2[0] = mk[4];
      ukey2[1] = mk[5];
      ukey2[2] = mk[6];
      ukey2[3] = mk[7];

      u32 ks1[44];
      u32 ks2[44];

      aes128_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes128_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain256 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
    else if (key_size == HC_LUKS_KEY_SIZE_512)
    {
      u32 ukey1[8];

      ukey1[0] = mk[ 0];
      ukey1[1] = mk[ 1];
      ukey1[2] = mk[ 2];
      ukey1[3] = mk[ 3];
      ukey1[4] = mk[ 4];
      ukey1[5] = mk[ 5];
      ukey1[6] = mk[ 6];
      ukey1[7] = mk[ 7];

      u32 ukey2[8];

      ukey2[0] = mk[ 8];
      ukey2[1] = mk[ 9];
      ukey2[2] = mk[10];
      ukey2[3] = mk[11];
      ukey2[4] = mk[12];
      ukey2[5] = mk[13];
      ukey2[6] = mk[14];
      ukey2[7] = mk[15];

      u32 ks1[60];
      u32 ks2[60];

      aes256_set_decrypt_key (ks1, ukey1, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
      aes256_set_encrypt_key (ks2, ukey2, s_te0, s_te1, s_te2, s_te3, s_te4);

      luks_decrypt_sector_aes_xts_plain512 (luks_bufs->ct_buf, pt_buf, ks1, ks2, 0, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);
    }
  }
}
