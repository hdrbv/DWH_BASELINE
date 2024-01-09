CREATE VIEW public.GMV AS
(SELECT
    pu.store_id,
    pr.category_id,
    SUM(pi.product_price * pi.product_count) AS sales_sum
FROM
    public.purchase_items pi
JOIN
    public.products pr ON pi.product_id = pr.product_id
JOIN
    public.purchases pu ON pi.purchase_id = pu.purchase_id
GROUP BY
    pu.store_id,
    pr.category_id
);

