function rand_vec = generate_rand_mutate(random_size)
rand_vec = rand(random_size);
rand_norm = sqrt(sum(rand_vec .^2));
rand_vec = 0*rand_vec / (rand_norm * 20);