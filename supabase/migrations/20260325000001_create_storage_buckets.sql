-- Migration : Créer les buckets Storage pour les photos produits et logos magasins
-- Date : 2026-03-25

-- Créer le bucket pour les photos de produits (publique)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Créer le bucket pour les logos de magasins (publique)
INSERT INTO storage.buckets (id, name, public)
VALUES ('store-logos', 'store-logos', true)
ON CONFLICT (id) DO NOTHING;

-- Politique RLS pour product-images : tout le monde peut lire
CREATE POLICY "Public read access for product images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- Politique RLS pour product-images : seuls les utilisateurs authentifiés peuvent uploader
CREATE POLICY "Authenticated users can upload product images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);

-- Politique RLS pour product-images : seuls les propriétaires peuvent mettre à jour/supprimer
CREATE POLICY "Store owners can update their product images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
)
WITH CHECK (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);

CREATE POLICY "Store owners can delete their product images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);

-- Politiques RLS pour store-logos (même logique)
CREATE POLICY "Public read access for store logos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'store-logos');

CREATE POLICY "Authenticated users can upload store logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'store-logos'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);

CREATE POLICY "Store owners can update their store logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'store-logos'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
)
WITH CHECK (
  bucket_id = 'store-logos'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);

CREATE POLICY "Store owners can delete their store logos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'store-logos'
  AND (storage.foldername(name))[1] = (auth.jwt() ->> 'store_id')
);
