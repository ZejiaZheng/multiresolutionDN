function rand_vec = generate_rand_mutate(random_size)
rand_vec = zeros(random_size);
rand_norm = sqrt(sum(rand_vec .^2));
rand_vec = rand_vec / (rand_norm * 20);