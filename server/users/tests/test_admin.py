from django.test import TestCase, Client
from django.contrib.auth import get_user_model
from django.urls import reverse


class AdminSiteTest(TestCase):

    def setUp(self) -> None:
        self.client = Client()
        User = get_user_model()
        self.admin_user = User.objects.create_superuser(
            email='admin@email.com',
            password='admin_password'
        )
        self.client.force_login(self.admin_user)
        self.user = User.objects.create_user(
            email='user@email.com',
            password='user_password',
            first_name='First Name',
            last_name='Last Name'
        )

    def test_users_listed(self):
        """Test that users are listed on user pages"""
        url = reverse('admin:users_user_changelist')
        res = self.client.get(url)

        self.assertContains(res, self.user.first_name)
        self.assertContains(res, self.user.last_name)
        self.assertContains(res, self.user.email)

    def test_user_change_page(self):
        """Test that the user edit page works"""
        url = reverse('admin:users_user_change', args=[self.user.id])
        res = self.client.get(url)

        self.assertEqual(res.status_code, 200)

    def test_create_user_page(self):
        """Test that the create user page works"""
        url = reverse('admin:users_user_add')
        res = self.client.get(url)

        self.assertEqual(res.status_code, 200)
